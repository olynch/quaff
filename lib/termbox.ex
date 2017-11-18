defmodule Termbox do
  @on_load :lib_init

  def lib_init() do
    :erlang.load_nif("/home/olynch/git/quaff/c_src/libextermbox", 0)
    :ok
  end

  def init() do
    IO.puts("Nif library not loaded")
  end

  def shutdown() do
    IO.puts("Nif library not loaded")
  end

  def change_cell(_x, _y, _ch, _fg, _bg) do
    IO.puts("Nif library not loaded")
  end

  def present() do
    IO.puts("Nif library not loaded")
  end

  def clear() do
    IO.puts("Nif library not loaded")
  end

  def width() do
    IO.puts("Nif library not loaded")
  end

  def height() do
    IO.puts("Nif library not loaded")
  end

  def subscribe(_pid) do
    IO.puts("Nif library not loaded")
  end

  def unsubscribe(_key) do
    IO.puts("Nif library not loaded")
  end

  # special keys ---------------

  def tbKEY_F1 , do: (0xFFFF-0)
  def tbKEY_F2 , do: (0xFFFF-1)
  def tbKEY_F3 , do: (0xFFFF-2)
  def tbKEY_F4 , do: (0xFFFF-3)
  def tbKEY_F5 , do: (0xFFFF-4)
  def tbKEY_F6 , do: (0xFFFF-5)
  def tbKEY_F7 , do: (0xFFFF-6)
  def tbKEY_F8 , do: (0xFFFF-7)
  def tbKEY_F9 , do: (0xFFFF-8)
  def tbKEY_F10 , do: (0xFFFF-9)
  def tbKEY_F11 , do: (0xFFFF-10)
  def tbKEY_F12 , do: (0xFFFF-11)
  def tbKEY_INSERT , do: (0xFFFF-12)
  def tbKEY_DELETE , do: (0xFFFF-13)
  def tbKEY_HOME , do: (0xFFFF-14)
  def tbKEY_END , do: (0xFFFF-15)
  def tbKEY_PGUP , do: (0xFFFF-16)
  def tbKEY_PGDN , do: (0xFFFF-17)
  def tbKEY_ARROW_UP , do: (0xFFFF-18)
  def tbKEY_ARROW_DOWN , do: (0xFFFF-19)
  def tbKEY_ARROW_LEFT , do: (0xFFFF-20)
  def tbKEY_ARROW_RIGHT , do: (0xFFFF-21)
  def tbKEY_MOUSE_LEFT , do: (0xFFFF-22)
  def tbKEY_MOUSE_RIGHT , do: (0xFFFF-23)
  def tbKEY_MOUSE_MIDDLE , do: (0xFFFF-24)
  def tbKEY_MOUSE_RELEASE , do: (0xFFFF-25)
  def tbKEY_MOUSE_WHEEL_UP , do: (0xFFFF-26)
  def tbKEY_MOUSE_WHEEL_DOWN , do: (0xFFFF-27)

  def tbKEY_CTRL_TILDE , do: 0x00
  def tbKEY_CTRL_2 , do: 0x00
  def tbKEY_CTRL_A , do: 0x01
  def tbKEY_CTRL_B , do: 0x02
  def tbKEY_CTRL_C , do: 0x03
  def tbKEY_CTRL_D , do: 0x04
  def tbKEY_CTRL_E , do: 0x05
  def tbKEY_CTRL_F , do: 0x06
  def tbKEY_CTRL_G , do: 0x07
  def tbKEY_BACKSPACE , do: 0x08
  def tbKEY_CTRL_H , do: 0x08
  def tbKEY_TAB , do: 0x09
  def tbKEY_CTRL_I , do: 0x09
  def tbKEY_CTRL_J , do: 0x0A
  def tbKEY_CTRL_K , do: 0x0B
  def tbKEY_CTRL_L , do: 0x0C
  def tbKEY_ENTER , do: 0x0D
  def tbKEY_CTRL_M , do: 0x0D
  def tbKEY_CTRL_N , do: 0x0E
  def tbKEY_CTRL_O , do: 0x0F
  def tbKEY_CTRL_P , do: 0x10
  def tbKEY_CTRL_Q , do: 0x11
  def tbKEY_CTRL_R , do: 0x12
  def tbKEY_CTRL_S , do: 0x13
  def tbKEY_CTRL_T , do: 0x14
  def tbKEY_CTRL_U , do: 0x15
  def tbKEY_CTRL_V , do: 0x16
  def tbKEY_CTRL_W , do: 0x17
  def tbKEY_CTRL_X , do: 0x18
  def tbKEY_CTRL_Y , do: 0x19
  def tbKEY_CTRL_Z , do: 0x1A
  def tbKEY_ESC , do: 0x1B
  def tbKEY_CTRL_LSQ_BRACKET , do: 0x1B
  def tbKEY_CTRL_3 , do: 0x1B
  def tbKEY_CTRL_4 , do: 0x1C
  def tbKEY_CTRL_BACKSLASH , do: 0x1C
  def tbKEY_CTRL_5 , do: 0x1D
  def tbKEY_CTRL_RSQ_BRACKET , do: 0x1D
  def tbKEY_CTRL_6 , do: 0x1E
  def tbKEY_CTRL_7 , do: 0x1F
  def tbKEY_CTRL_SLASH , do: 0x1F
  def tbKEY_CTRL_UNDERSCORE , do: 0x1F
  def tbKEY_SPACE , do: 0x20
  def tbKEY_BACKSPACE2 , do: 0x7F
  def tbKEY_CTRL_8 , do: 0x7F

  def tbMOD_ALT , do: 0x01

  # attributes ----------------------

  def tbDEFAULT , do: 0x00
  def tbBLACK , do: 0x01
  def tbRED , do: 0x02
  def tbGREEN , do: 0x03
  def tbYELLOW , do: 0x04
  def tbBLUE , do: 0x05
  def tbMAGENTA , do: 0x06
  def tbCYAN , do: 0x07
  def tbWHITE , do: 0x08

  def tbBOLD , do: 0x0100
  def tbUNDERLINE , do: 0x0200
  def tbREVERSE , do: 0x0400

  # misc ----------------------------

  def tbHIDE_CURSOR , do: -1
  def tbINPUT_CURRENT , do: 0
  def tbINPUT_ESC , do: 1
  def tbINPUT_ALT , do: 2
  def tbOUTPUT_CURRENT , do: 0
  def tbOUTPUT_NORMAL , do: 1
  def tbOUTPUT_256 , do: 2
  def tbOUTPUT_216 , do: 3
  def tbOUTPUT_GRAYSCALE , do: 4
  def tbEVENT_KEY , do: 1
  def tbEVENT_RESIZE , do: 2
  def tbEVENT_MOUSE , do: 3

  # def tb_peek_event(_timeout)
end
