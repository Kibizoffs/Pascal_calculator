Program Calculator;

uses
    Crt, IniFiles, { стандартные модули }
    Global,        { глобальные переменные }
    Handler,       { модуль по обработки ошибок }
    Parser;        { модуль по обработки ввода }

var
    eps_str: string;
    ini:     TIniFile;

begin
    ClrScr();
    NormVideo();

    debug := false;
    ini := TIniFile.Create('config.ini');
    if ini.ReadString('Settings', 'debug', '0') = '1' then
        debug := true;

    if (ParamCount() < 2) or (ParamCount() > 256) then { некорректное кол-во аргументов } 
        Write_err(MSG_WRITE_EPS_AND_BASES);

    eps_str := paramStr(1); { paramStr(0) равен названию исполняемого файла }

    { получение eps_dbl }
    if eps_str[2] = ',' then
        eps_str[2] := '.';
    Val(eps_str, eps_dbl, code);
    if (code <> 0) or (eps_dbl <= 0) or (eps_dbl > 1) then
        Write_err(MSG_WRITE_EPS_AND_BASES);

    { заполнение массива bases }
    SetLength(bases, ParamCount() - 1);
    for i := 2 to ParamCount do
    begin
        { можно было бы отсортировать СС и исключить дупликаты }
        val(ParamStr(i), bases[i-1], code);
        if (code <> 0) or (bases[i-1] < 2) or (bases[i-1] > 256) then { недопустимая СС }
            Write_err(MSG_WRITE_EPS_AND_BASES)
    end;

    result := 0;
    result_fraction.numerator := 0;
    result_fraction.denominator := 1;
    result_fraction.non_negative := true;

    Parse_input() { процедура из Parser }
end.
