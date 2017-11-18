#include "erl_nif.h"
#include <termbox.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static ErlNifMutex* g_lock = NULL;

typedef struct _sub_item_t
{
  ErlNifPid* pid;
  int key;
  struct _sub_item_t* next;
} sub_item_t;

typedef struct _sub_list_t
{
  sub_item_t* head;
  ErlNifMutex* lock;
  ErlNifCond* started;
  int serial;
} sub_list_t;

typedef struct _state_t
{
  ErlNifTid subthread;
  ErlNifThreadOpts* opts;
  sub_list_t* sub_list;
} state_t;

sub_list_t* sub_list_create() {
  sub_list_t* ret;

  ret = (sub_list_t*) enif_alloc(sizeof(sub_list_t));
  if(ret == NULL) return NULL;

  ret->lock = enif_mutex_create("sl_lock");
  if(ret->lock == NULL) goto error;

  ret->started = enif_cond_create("started");
  if(ret->started == NULL) goto error;


  ret->head = NULL;
  ret->serial = 0;

  return ret;

error:
  if(ret->lock != NULL) enif_mutex_destroy(ret->lock);
  if(ret->started != NULL) enif_cond_destroy(ret->started);
  if(ret != NULL) enif_free(NULL);
  return NULL;
}

void sub_list_destroy(sub_list_t* sub_list) {
  ErlNifMutex* lock;

  enif_mutex_lock(sub_list->lock);
  sub_item_t* item = sub_list->head;
  sub_item_t* to_delete;
  while (item != NULL) {
    to_delete = item;
    item = item->next;
    enif_free(to_delete->pid);
    enif_free(to_delete);
  }
  enif_cond_destroy(sub_list->started);
  lock = sub_list->lock;
  sub_list->lock = NULL;
  enif_mutex_unlock(lock);

  enif_mutex_destroy(lock);
  enif_free(sub_list);
}

int sub_list_push(sub_list_t* sub_list, ErlNifPid* pid) {
  sub_item_t* item = (sub_item_t*) enif_alloc(sizeof(sub_item_t));
  if (item == NULL) return -1;

  item->pid = pid;

  enif_mutex_lock(sub_list->lock);

  item->next = sub_list->head;
  item->key = sub_list->serial;
  sub_list->head = item;
  sub_list->serial++;

  enif_mutex_unlock(sub_list->lock);

  return item->key;
}

int sub_list_remove(sub_list_t* sub_list, int key) {
  enif_mutex_lock(sub_list->lock);

  sub_item_t* item = sub_list->head;
  sub_item_t* parent = NULL;
  while (item != NULL) {
    if (item->key == key) {
      if (parent == NULL) {
        sub_list->head = item->next;
      } else {
        parent->next = item->next;
      }
      enif_free(item->pid);
      enif_free(item);
      
      enif_mutex_unlock(sub_list->lock);
      return 0;
    } else {
      parent = item;
      item = item->next;
    }
  }

  enif_mutex_unlock(sub_list->lock);

  return -1;
}

static void* thr_main(void* obj) {
  state_t* state = (state_t*) obj;
  ErlNifEnv* env = enif_alloc_env();
  struct tb_event e;
  ERL_NIF_TERM msg;
  sub_item_t* item;
  sub_list_t* sub_list = state->sub_list;
  enif_mutex_lock(sub_list->lock);
  enif_cond_wait(sub_list->started, sub_list->lock);
  enif_mutex_unlock(sub_list->lock);
  while (tb_poll_event(&e) >= 0) {
    //printf("received event\n");
    enif_mutex_lock(sub_list->lock);
    item = sub_list->head;
    if (item == NULL) {
      continue;
    } else if (item->pid == NULL) {
      break;
    } else {
      while (item != NULL) {
        //printf("sending keypress %d to key %d\n", e.ch, item->key);
        msg = enif_make_tuple9(
            env,
            enif_make_atom(env, "keyboard"),
            enif_make_int(env, (int) e.type),
            enif_make_int(env, (int) e.mod),
            enif_make_int(env, (int) e.key),
            enif_make_int(env, (int) e.ch),
            enif_make_int(env, (int) e.w),
            enif_make_int(env, (int) e.h),
            enif_make_int(env, (int) e.x),
            enif_make_int(env, (int) e.y)
            );
        enif_send(NULL, item->pid, env, msg);
        enif_clear_env(env);
        item = item->next;
      }
    }
    enif_mutex_unlock(sub_list->lock);
  }

  return NULL;
}

static int load(ErlNifEnv* env, void** priv, ERL_NIF_TERM load_info) {
  /* FILE* log = fopen("log", "w+"); */
  /* f//printf(log, "Loading library!\n"); */
  /* fclose(log); */
  g_lock = enif_mutex_create("g_lock");

  state_t* state = (state_t*) enif_alloc(sizeof(state_t));
  if (state == NULL) goto error;

  state->sub_list = sub_list_create();
  if (state->sub_list == NULL) goto error;

  state->opts = enif_thread_opts_create("thread_opts");
  if (enif_thread_create("", &(state->subthread), thr_main, state, state->opts) != 0) {
    goto error;
  }

  *priv = (void*) state;

  return 0;

error:
  if (g_lock != NULL) enif_mutex_destroy(g_lock);
  if (state->sub_list != NULL) sub_list_destroy(state->sub_list);
  return -1;
}

static void unload(ErlNifEnv* env, void* priv) {
  state_t* state = (state_t*) priv;
  void* resp;

  if (g_lock != NULL) enif_mutex_destroy(g_lock);

  sub_list_push(state->sub_list, NULL);
  enif_thread_join(state->subthread, &resp);
  sub_list_destroy(state->sub_list);

  enif_thread_opts_destroy(state->opts);
  enif_free(state);
}


static ERL_NIF_TERM
ok(ErlNifEnv* env) {
  return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM
erl_tb_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  enif_mutex_lock(g_lock);
  tb_init();
  enif_mutex_unlock(g_lock);

  state_t* state = (state_t*) enif_priv_data(env);
  enif_cond_broadcast(state->sub_list->started);

  return ok(env);
}

static ERL_NIF_TERM
erl_tb_shutdown(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  enif_mutex_lock(g_lock);
  tb_shutdown();
  enif_mutex_unlock(g_lock);

  return ok(env);
}

static ERL_NIF_TERM
erl_tb_change_cell(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  int x, y, ch, fg, bg;

  enif_get_int(env, argv[0], &x);
  enif_get_int(env, argv[1], &y);
  enif_get_int(env, argv[2], &ch);
  enif_get_int(env, argv[3], &fg);
  enif_get_int(env, argv[4], &bg);

  enif_mutex_lock(g_lock);
  tb_change_cell(x, y, (uint32_t) ch, (uint16_t) fg, (uint16_t) bg);
  enif_mutex_unlock(g_lock);

  return ok(env);
}

static ERL_NIF_TERM
erl_tb_present(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  enif_mutex_lock(g_lock);
  tb_present();
  enif_mutex_unlock(g_lock);

  return ok(env);
}


static ERL_NIF_TERM
erl_tb_width(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  enif_mutex_lock(g_lock);
  int w = tb_width();
  enif_mutex_unlock(g_lock);

  return enif_make_int(env, w);
}

static ERL_NIF_TERM
erl_tb_height(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  enif_mutex_lock(g_lock);
  int h = tb_height();
  enif_mutex_unlock(g_lock);

  return enif_make_int(env, h);
}

static ERL_NIF_TERM
erl_tb_clear(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  enif_mutex_lock(g_lock);
  tb_clear();
  enif_mutex_unlock(g_lock);

  return ok(env);
}

static ERL_NIF_TERM
erl_subscribe(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  state_t* state = (state_t*) enif_priv_data(env);
  ErlNifPid* pid = (ErlNifPid*) enif_alloc(sizeof(ErlNifPid));

  if (!enif_get_local_pid(env, argv[0], pid)) {
    return enif_make_badarg(env);
  }

  int key = sub_list_push(state->sub_list, pid);

  //printf("subscribed with id %d\n", key);

  return enif_make_tuple2(env, ok(env), enif_make_int(env, key));
}

static ERL_NIF_TERM
erl_unsubscribe(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  state_t* state = (state_t*) enif_priv_data(env);

  int key;
  enif_get_int(env, argv[0], &key);

  sub_list_remove(state->sub_list, key);
  //printf("unsubscribed id %d\n", key);

  return ok(env);
}

static ErlNifFunc nif_funcs[] = {
  {"init", 0, erl_tb_init},
  {"shutdown", 0, erl_tb_shutdown},
  {"change_cell", 5, erl_tb_change_cell},
  {"present", 0, erl_tb_present},
  {"width", 0, erl_tb_width},
  {"height", 0, erl_tb_height},
  {"clear", 0, erl_tb_clear},
  {"subscribe", 1, erl_subscribe},
  {"unsubscribe", 1, erl_unsubscribe}
};

ERL_NIF_INIT(Elixir.Termbox, nif_funcs, load, NULL, NULL, unload)
