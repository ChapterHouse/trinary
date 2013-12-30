[[0, -1, 1], [-1, 0, 1], "SwapPC"]
[[0, -1, 1], [-1, 0, 1], "SwapCSShiftR"]
[[0, -1, 1], [-1, 0, 1], "SwapPSShiftL"]
----
[[-1, 1, 0], [-1, 0, 1], "SwapCS"]
[[-1, 1, 0], [-1, 0, 1], "SwapPCShiftL"]
[[-1, 1, 0], [-1, 0, 1], "SwapPSShiftR"]
----
[[1, 0, -1], [-1, 0, 1], "SwapPS"]
[[1, 0, -1], [-1, 0, 1], "SwapPCShiftR"]
[[1, 0, -1], [-1, 0, 1], "SwapCSShiftL"]
----
[[-1, 0, 1], [0, -1, 1], "SwapTH"]
[[-1, 0, 1], [0, -1, 1], "SwapHBShiftD"]
[[-1, 0, 1], [0, -1, 1], "SwapTBShiftU"]
----
[[-1, 0, 1], [-1, 1, 0], "SwapHB"]
[[-1, 0, 1], [-1, 1, 0], "SwapTHShiftU"]
[[-1, 0, 1], [-1, 1, 0], "SwapTBShiftD"]
----
[[-1, 0, 1], [1, 0, -1], "SwapTB"]
[[-1, 0, 1], [1, 0, -1], "SwapTHShiftD"]
[[-1, 0, 1], [1, 0, -1], "SwapHBShiftU"]

duplications =
    {
        'SwapPC' => ['SwapCSShiftR', 'SwapPSShiftL'],
        'SwapCS' => ['SwapPCShiftL', 'SwapPSShiftR'],
        'SwapPS' => ['SwapPCShiftR', 'SwapCSShiftL'],
        'SwapTH' => ['SwapHBShiftD', 'SwapTBShiftU'],
        'SwapHB' => ['SwapTHShiftU', 'SwapTBShiftD'],
        'SwapTB' => ['SwapTHShiftD', 'SwapHBShiftU']
    }







