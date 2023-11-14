unit Global;

interface
    type
        fraction_rec = record
            numerator:    longint;
            denominator:  longword;
            non_negative: boolean
        end;

    const
        MAX_INT64      = high(int64);
        MAX_LONGWORD   = high(longword);

    var
        i, j, code:              integer;
        eps_dbl, result:         double;
        val_int64:               int64;
        val_qword:               qword;
        debug, flag:             boolean;
        bases:                   array of word;
        result_fraction:         fraction_rec;
        

implementation
end.
