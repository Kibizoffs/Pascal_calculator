unit Operations;

interface
    uses
        Global, { глобальные переменные }
        Parser; { модуль по обработки ввода }

    var
        base_str, numerator_str, denominator_str, result_str: string;
        results:                                              array of string;

    procedure Convert_to_10(base_input: string; numerator_input: string; denominator_input: string);

    procedure Convert_from_10();

implementation
    uses
        Math,      { стандартные модули }
        Answers,   { модуль по реализации вывода }
        Handler;   { модуль по обработки ошибок }

    const
        MAX_INTEGER  = high(integer);
        MAX_LONGINT  = high(longint);

    var
        n:         integer;
        m:         qword;
        remainder: longword;

    { получить обработанный ord символа }
    function Calculated_ord(char_to_ord: char): integer;
    begin
        if ('0' <= char_to_ord) and (char_to_ord <= '9') then { обработка [0-9] }
            Calculated_ord := ord(char_to_ord) - 48
        else
        begin
            if ('a' <= char_to_ord) and ('f' >= char_to_ord) then { обработка [a-f] }
                Calculated_ord := ord(char_to_ord) - 87
            else Write_err(MSG_BAD_SYMBOL)
        end;
    end;

    { получить обработанный chr символа }
    function Calculated_chr(int_to_char: integer): char;
    begin
        if (0 <= int_to_char) and (int_to_char <= 9) then { обработка [0-9] }
            Calculated_chr := chr(int_to_char + 48)
        else if (10 <= int_to_char) and (int_to_char <= 15) then { обработка [10-15] }
            Calculated_chr := chr(int_to_char + 87)
    end;

    { НОД }
    function Gcd(a: longword; b: longword): longword;
    begin
        while (a <> 0) and (b <> 0) do
        begin
            if a >= b then a := a mod b
            else b := b mod a;
        end;
        Gcd := a + b
    end;

    { НОК }
    function Lcm(a: longword; b: longword): QWord;
    begin
        val_int64 := a * b;
        if val_int64 > MAX_LONGWORD then
            Write_err(MSG_TOO_LARGE_NUM);
        Lcm := val_int64 div Gcd(a, b)
    end;

    { сократить дробь }
    function Shortened_fraction(fraction: fraction_rec): fraction_rec;
    var
        divider: longword;
    begin
        divider := Gcd(fraction.numerator, fraction.denominator);
        Shortened_fraction.numerator := fraction.numerator div divider;
        Shortened_fraction.denominator := fraction.denominator div divider;
        Shortened_fraction.non_negative := fraction.non_negative
    end;

    { представить целую и десятичную часть в данной СС }
    procedure Calculated_eps(base: word);
    var
        eps_trunc:   longword;
        eps_frac:    double;
    begin
        result_str := '';
        eps_trunc := trunc(abs(result));
        if eps_trunc = 0 then
            result_str := result_str + ' 00'; 
        while eps_trunc > 0 do { целая часть }
        begin
            remainder := eps_trunc mod base;
            result_str := ' ' + Calculated_chr(remainder div 16) + Calculated_chr(remainder mod 16) + result_str;
            eps_trunc := eps_trunc div base
        end;
        if result < 0 then
            result_str := ' -' + result_str; 
            
        m := 1;
        n := 1;
        while eps_dbl < (1 / (base * m)) do { критерий-неравенство для округления по эпсилону }
        begin
            val_int64 := m * base;
            if val_int64 > MAX_LONGWORD then
                break;
            m := val_int64;
            n := n + 1;
        end;
        eps_frac := abs(result) - Trunc(abs(result));
        eps_frac := RoundTo(eps_frac, (-1) * (n + 1));
        result_str := result_str + ' . ';
        for j := 1 to n do { десятичная часть }
        begin
            eps_trunc := Trunc(eps_frac * base);
            eps_frac := eps_frac * base - eps_trunc;
            result_str := result_str + Calculated_chr(eps_trunc div 16) + Calculated_chr(eps_trunc mod 16) + ' '
        end
    end;

    { произвести численную операцию }
    procedure Calculate_fraction(operation: char; fraction: fraction_rec); { вычислить операцию }
    var
        lcm_num:              LongWord;
        temp:                 LongWord;
        result_fraction_copy: fraction_rec;
    begin
        result_fraction_copy.numerator := result_fraction.numerator;
        result_fraction_copy.denominator := result_fraction.denominator;
        result_fraction_copy.non_negative := result_fraction.non_negative;

        if debug then
        begin
            Write('Вычисляю: ');
            if result_fraction_copy.non_negative = false then
                write('-');
            Write(result_fraction_copy.numerator, '/', result_fraction_copy.denominator, ' ', operation, ' ');
            if fraction.non_negative = false then
                Write('-');
            Write(fraction.numerator, '/', fraction.denominator)
        end;
        
        case operation of  
            '-' :
            begin
                fraction.non_negative := not(fraction.non_negative);
                operation := '+'
            end;
            '/' :
            begin
                temp := fraction.numerator;
                if fraction.denominator > MAX_LONGINT then
                    Write_err(MSG_TOO_LARGE_DENOMINATOR);
                if fraction.numerator = 0 then
                    Write_err(MSG_DIVISION_BY_ZERO);
                fraction.numerator := fraction.denominator;
                fraction.denominator := temp;
                operation := '*'
            end;  
        end;
        case operation of  
            '+':
            begin
                lcm_num := Lcm(fraction.denominator, result_fraction_copy.denominator);

                m := lcm_num div result_fraction_copy.denominator;
                val_int64 := result_fraction_copy.numerator * m;
                if val_int64 > MAX_LONGINT then
                    Write_err(MSG_TOO_LARGE_NUM);
                result_fraction_copy.numerator := val_int64;

                m := lcm_num div fraction.denominator;
                val_int64 := fraction.numerator * m;
                if val_int64 > MAX_LONGINT then
                    Write_err(MSG_TOO_LARGE_NUM);
                fraction.numerator := val_int64;

                result_fraction_copy.denominator := lcm_num;
                fraction.denominator := lcm_num;

                if result_fraction_copy.non_negative = fraction.non_negative then
                begin
                    val_int64 := result_fraction_copy.numerator + fraction.numerator;
                    if val_int64 > MAX_LONGINT then
                        Write_err(MSG_TOO_LARGE_NUM);
                    result_fraction_copy.numerator := val_int64
                end
                else
                begin
                    if result_fraction_copy.numerator < fraction.numerator then
                        result_fraction_copy.non_negative := not(result_fraction_copy.non_negative);
                    val_int64 := abs(result_fraction_copy.numerator - fraction.numerator);
                    if val_int64 > MAX_LONGINT then
                        Write_err(MSG_TOO_LARGE_NUM);
                    result_fraction_copy.numerator := val_int64
                end;
            end;
            '*':
            begin
                val_int64 := result_fraction_copy.numerator * fraction.numerator;
                if val_int64 > MAX_LONGINT then
                    Write_err(MSG_TOO_LARGE_NUM);
                result_fraction_copy.numerator := val_int64;

                val_int64 := result_fraction_copy.denominator * fraction.denominator;
                if val_int64 > MAX_LONGWORD then
                    Write_err(MSG_TOO_LARGE_NUM);
                result_fraction_copy.denominator := val_int64;

                if result_fraction_copy.non_negative = fraction.non_negative then
                    result_fraction_copy.non_negative := true
                else result_fraction_copy.non_negative := false;
            end;  
        end;
        result_fraction := Shortened_fraction(result_fraction_copy);

        result := result_fraction.numerator / result_fraction.denominator;
        if result_fraction.non_negative = false then
            result := result * (-1);

        if debug then
        begin
            Write(' = ');
            if result_fraction.non_negative = false then
                Write('-');
            WriteLn(result_fraction.numerator, '/', result_fraction.denominator)
        end
    end;

    { перевести в 10-ую СС }
    procedure Convert_to_10(base_input: string; numerator_input: string; denominator_input: string);
    var
        num_inside: longword;
        base:       word;
        fraction:   fraction_rec;
    begin
        Val(base_input, base, code);
        if (code <> 0) or (base < 2) or (base > 256) then
            Write_err(MSG_BAD_BASE);

        fraction.numerator := 0;
        fraction.denominator := 0; { (знаменатель <> 0) проверяется позже }
        fraction.non_negative := true;

        if numerator_input[1] = '-' then
        begin
            numerator_input := Copy(numerator_input, 2, Length(numerator_input));
            fraction.non_negative := false
        end;

        if Length(numerator_input) mod 2 = 1 then
            Write_err(MSG_BAD_NUMERATOR);
        if Length(denominator_input) mod 2 = 1 then
            Write_err(MSG_BAD_DENOMINATOR);

        m := 1;
        for i := (Length(numerator_input) div 2) downto 1 do { перевести числитель }
        begin
            num_inside := Calculated_ord(numerator_input[i*2-1]) * 16 + Calculated_ord(numerator_input[i*2]);
            if base <= num_inside then
                Write_err(MSG_BAD_NUMERATOR);
                
            val_int64 := fraction.numerator + num_inside * m;
            if val_int64 > MAX_LONGINT then
                Write_err(MSG_TOO_LARGE_NUM);
            fraction.numerator := val_int64;
            val_qword := m * base;
            if val_qword > MAX_INT64 then
                Write_err(MSG_TOO_LARGE_NUM);
            m := val_qword
        end;
        if fraction.numerator = 0 then
            fraction.non_negative := true;

        m := 1;
        for i := (Length(denominator_input) div 2) downto 1 do { перевести знаменатель }
        begin
            num_inside := Calculated_ord(denominator_input[i*2-1]) * 16 + Calculated_ord(denominator_input[i*2]);
            if base <= num_inside then
                Write_err(MSG_BAD_DENOMINATOR);
            val_int64 := fraction.denominator + num_inside * m;
            if val_int64 > MAX_LONGWORD then
                Write_err(MSG_TOO_LARGE_NUM);
            fraction.denominator := val_int64;
            val_qword := m * base;
            if val_qword > MAX_INT64 then
                Write_err(MSG_TOO_LARGE_NUM);
            m := val_qword
        end;

        if fraction.denominator = 0 then
            Write_err(MSG_DIVISION_BY_ZERO);
        fraction := Shortened_fraction(fraction);
        Calculate_fraction(operation_input, fraction);
    end;

    { перести из 10-ой СС }
    procedure Convert_from_10();
    var
        fraction: fraction_rec;
    begin
        for i := 1 to Length(bases) do
        begin
            numerator_str := '';
            denominator_str := '';
            fraction.numerator := result_fraction.numerator;
            fraction.denominator := result_fraction.denominator;
            fraction.non_negative := result_fraction.non_negative;
            while fraction.numerator > 0 do
            begin   
                remainder := fraction.numerator mod bases[i];
                numerator_str := ' ' + Calculated_chr(remainder div 16) + Calculated_chr(remainder mod 16) + numerator_str;
                fraction.numerator := fraction.numerator div bases[i];
            end;
            if numerator_str = '' then
                numerator_str := ' 00';
            if fraction.non_negative = false then
                numerator_str := ' -' + numerator_str;

            while fraction.denominator > 0 do
            begin   
                remainder := fraction.denominator mod bases[i];
                denominator_str := ' ' + Calculated_chr(remainder div 16) + Calculated_chr(remainder mod 16) + denominator_str;
                fraction.denominator := fraction.denominator div bases[i];
            end;

            Calculated_eps(bases[i]);

            Write_ans()
        end;
    end;
end.
