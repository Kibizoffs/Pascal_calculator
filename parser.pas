unit Parser;

interface
    var 
        finish_count:                                   integer;
        ch_pos:                                         longword;
        ch, operation_input:                            char;
        base_input, numerator_input, denominator_input: string;
        show_full_err:                                  boolean;

    procedure Parse_input();


implementation
    uses
        Crt,        { стандартный модуль }
        Global,     { глобальные переменные }
        Handler,    { модуль по обработки ошибок }
        Operations; { модуль по вычислениям }

    const
        CH_NULL: char = #0;
        CH_EOLN: char = #10;

    procedure Restore_default(); { восстановить исходные значения }
    begin
        ch := CH_NULL;
        ch_pos := 0;
        operation_input := CH_NULL;
        base_input := '';
        numerator_input := '';
        denominator_input := '';
    end;

    { игнорировать комменты }
    procedure Ignore_comments();
    begin
        if ch = ';' then
            repeat Read(ch) until ch = CH_EOLN;
        ch := CH_NULL;
        ch_pos := 0
    end;
    
    { проверить пробельный символ }
    function Check_space(): boolean;
    var
        spaces: array[1..4] of char = (#0, #9, #13, #32);
    begin
        Check_space := false;
        for i := 1 to Length(spaces) do { проверка с пробельными символами }
        begin
            if ch = spaces[i] then
            begin
                Check_space := true;
                break
            end
        end
    end;

    procedure Stop_parsing();
    begin
        Convert_from_10();
        Halt(0)
    end;

    { обработать символ }
    procedure Parse_char();
    const
        FINISH: string = 'finish';   
    begin
        if LowerCase(ch) = FINISH[finish_count] then
        begin
            if finish_count = Length(FINISH) then
                Stop_parsing()
            else finish_count := finish_count + 1
        end
        else
        begin
            if EOF and show_full_err then Write_err(MSG_NO_INPUT);
            if (finish_count > 1) or (Check_space() = false) then
                Write_err(MSG_BAD_SYMBOL);
        end;
    end;

    { обработать ввод }
    procedure Parse_input();
    var
        operations: array[1..4] of char = ('+', '-', '*', '/');
    begin
        finish_count := 1;
        show_full_err := true;

        Read(input);
        while true do { чтение ввода }
        begin
            Restore_default();

            while true do { ввод оператора }
            begin
                if EOF then
                    Stop_parsing();
                Read(input, ch);
                if ch_pos = MAX_LONGWORD then
                    Write_err(MSG_TOO_LARGE_STR);
                ch_pos := ch_pos + 1;
                if EOLN and (finish_count = 1) then continue;
                if (ch = ';') and (operation_input <> CH_NULL) then 
                    Write_err(MSG_BAD_SYMBOL);
                if ch = ';' then
                begin
                    Ignore_comments(); { читать до EOLN }
                    continue
                end;

                for i := 1 to Length(operations) do
                begin
                    if ch = operations[i] then
                    begin
                        if operation_input <> CH_NULL then { если оператор уже был найден в команде }
                            Write_err(MSG_BAD_SYMBOL);
                        operation_input := ch;
                        Read(input, ch);
                        if ch_pos = MAX_LONGWORD then
                            Write_err(MSG_TOO_LARGE_STR);
                        ch_pos := ch_pos + 1;
                        if Check_space = false then
                            Write_err(MSG_BAD_SYMBOL);
                        break
                    end;
                end;
                if (ch >= '0') and (ch <= '9') then
                begin
                    if operation_input = CH_NULL then { если оператор ещё не был найден }
                        Write_err(MSG_BAD_OPERATOR);
                    base_input := base_input + ch;
                    break
                end
                else Parse_char()
            end;
            if debug then
                WriteLn('Оператор: ', operation_input);

            while true do { ввод СС }
            begin
                if EOF then
                    Stop_parsing();
                Read(ch);
                if ch_pos = MAX_LONGWORD then
                    Write_err(MSG_TOO_LARGE_STR);
                ch_pos := ch_pos + 1;
                if (ch = ';') or
                (ch = ':') and (base_input = '') then
                    Write_err(MSG_BAD_BASE);
                if (ch = ':') then break;

                if (ch >= '0') and (ch <= '9') then
                begin
                    if Length(base_input) >= 3 then
                        Write_err(MSG_BAD_BASE);
                    base_input := base_input + ch
                end
                else Parse_char()
            end;
            if debug then
                WriteLn('СС: ', base_input);

            while true do { ввод числителя }
            begin
                if EOF then
                    Stop_parsing();
                Read(input, ch);
                if ch_pos = MAX_LONGWORD then
                    Write_err(MSG_TOO_LARGE_STR);
                ch_pos := ch_pos + 1;
                if (ch = ';') or
                (ch = '/') and (numerator_input = '') or { пустой числитель }
                (ch = '-') and (numerator_input <> '') { '-' в середине числа }
                    then Write_err(MSG_BAD_NUMERATOR);       
                if (ch = '/') then break;

                if (ch = '-') or
                (ch >= '0') and (ch <= '9') or
                (LowerCase(ch) >= 'a') and (LowerCase(ch) <= 'f') then
                    numerator_input := numerator_input + LowerCase(ch)
                else Parse_char()
            end;
            if debug then
                WriteLn('Числитель: ', numerator_input);

            while true do { ввод знаменателя }
            begin
                if EOF then
                    Stop_parsing();
                Read(input, ch);
                if ch_pos = MAX_LONGWORD then
                    Write_err(MSG_TOO_LARGE_STR);
                ch_pos := ch_pos + 1;
                if (ch = ';') and (denominator_input <> CH_NULL) then
                begin
                    Ignore_comments(); { читать до EOLN }
                    break
                end;
                if ((ch = CH_EOLN) or (ch = ';')) and
                (denominator_input = '') then
                    Write_err(MSG_BAD_DENOMINATOR);
                if ch = CH_EOLN then break;

                if (ch >= '0') and (ch <= '9') or
                (LowerCase(ch) >= 'a') and (LowerCase(ch) <= 'f') then
                    denominator_input := denominator_input + LowerCase(ch)
                else Parse_char()
            end;
            if debug then
                WriteLn('Знаменатель: ', denominator_input);

            Convert_to_10(base_input, numerator_input, denominator_input); { процедура из Operations }
            show_full_err := false;
        end;
    end;
end.
