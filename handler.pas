unit Handler;

interface

const
    MSG_WRITE_EPS_AND_BASES   = 'ERR0: Укажите (0 < эпсилон <= 1) и (2 <= СС <= 256) в 10-ой СС после названия файла';
    MSG_BAD_SYMBOL            = 'ERR1: Плохой символ';
    MSG_BAD_OPERATOR          = 'ERR2: Плохой оператор';
    MSG_BAD_BASE              = 'ERR3: Плохая СС';
    MSG_BAD_NUMERATOR         = 'ERR4: Плохой числитель';
    MSG_TOO_LARGE_MUMERATOR   = 'ERR5: Cлишком большой числитель';
    MSG_BAD_DENOMINATOR       = 'ERR6: Плохой знаменатель';
    MSG_TOO_LARGE_DENOMINATOR = 'ERR7: Cлишком большой знаменатель';
    MSG_TOO_LARGE_NUM         = 'ERR8: Переполнение типа';
    MSG_TOO_LARGE_STR         = 'ERR9: Слишком длинная строка';
    MSG_DIVISION_BY_ZERO      = 'ERR10: Деление на 0';
    MSG_NO_INPUT              = 'ERR11: Пустой ввод (не была введена ни одна корректная команда)';

procedure Write_err(msg: string);


implementation

uses
    Crt,        { стандартный модуль }
    Global,     { глобальные переменные }
    Operations, { модуль по вычислениям }
    Parser;     { модуль по обработке вывода }

procedure Write_err(msg: string); { вывести ошибку }
begin
    TextColor(Red);

    WriteLn(msg);
    if Copy(msg, 4, 2) = '1:' then { ERR1 }
    begin
        WriteLn('Код символа: ', ord(ch));
        if ch_pos <> 0 then
            WriteLn('Позиция символа: ', ch_pos)
    end;
    if show_full_err = true then
    begin
        Write('Результат до ошибки:');
        if result < 0 then
            Write(' ');
        WriteLn(result)
    end
    else
    begin
        WriteLn('Результат до ошибки');
        WriteLn('------');
        NormVideo();
        Convert_from_10();
        TextColor(Red);
        WriteLn('------');
    end;

    NormVideo();
    Halt(1)
end;
end.
