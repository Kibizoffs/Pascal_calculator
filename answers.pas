unit Answers;

interface
uses
    Crt,        { стандартный модуль }
    Global,     { глобальные переменные }
    Handler,    { модуль по обработки ошибок }
    Operations, { модуль по вычислениям }
    Parser;     { модуль по обработке вывода }
    
procedure Write_ans();


implementation

procedure Write_ans();
var
    spaces: string;
begin
    if show_full_err = true then Write_err(MSG_NO_INPUT);
    TextColor(Green);
    Write(bases[i]);
    NormVideo();
    if (100 <= bases[i]) and (bases[i] <= 256) then
        spaces := '   '
    else if (10 <= bases[i]) and (bases[i] <= 99) then
        spaces := '    '
    else if (2 <= bases[i]) and (bases[i] <= 9) then
        spaces := '     ';
    WriteLn(spaces, numerator_str, ' /', denominator_str);
    WriteLn('      ', result_str)
end;
end.
