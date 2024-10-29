repeat Wait(5) until Config ~= nil

Config.bankLocations = {
    {
        name = "Pillbox",
        coords = vector3(150.0243, -1040.7759, 29.3741),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("v_ilev_gb_vauldr"),
                coords = vector3(147.25, -1046.259, 29.46812),
                rotation = -110.1538
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(150.62, -1045.29, 28.34), rotation = 160.0},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(146.76, -1049.98, 28.34), rotation = 300.0},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(149.78, -1050.99, 28.34), rotation = 20.0}
            }
        }
    },
    {
        name = "Vinewood",
        coords = vector3(312.358, -282.7301, 73.15365),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("v_ilev_gb_vauldr"),
                coords = vector3(311.5875, -284.6257, 54.26483),
                rotation = -110.134
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(314.98, -284.01, 53.14), rotation = 139.14},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(311.02, -288.16, 53.14), rotation = 301.99},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(314.15, -289.4, 53.14), rotation = 26.81}
            }
        }
    },
    {
        name = "Hardwick",
        coords = vector3(-352.7365, -53.57248, 48.02543),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("v_ilev_gb_vauldr"),
                coords = vector3(-353.48, -55.48119, 49.13662),
                rotation = -109.1402
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-350.0, -54.72, 48.01), rotation = 135.15},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-353.95, -59.09, 48.01), rotation = 298.21},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-350.84, -60.16, 48.16), rotation = 28.58}
            }
        }
    },
    {
        name = "Del Perro",
        coords = vector3(-1211.261, -334.5596, 40.76989),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("v_ilev_gb_vauldr"),
                coords = vector3(-1210.42, -336.43, 37.88108),
                rotation = -63.13626
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-1208.64, -333.45, 36.75), rotation = 194.95},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-1208.18, -339.3, 36.75), rotation = 342.56},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-1205.21, -337.77, 36.75), rotation = 73.64}
            }
        }
    },
    {
        name = "Ocean",
        coords = vector3(-2958.539, 482.2706, 14.68594),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("hei_prop_heist_sec_door"),
                coords = vector3(-2956.5, 482.064, 15.79713),
                rotation = -2.457949
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-2958.09, 485.19, 14.67), rotation = 257.58},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-2952.8, 482.73, 14.67), rotation = 51.61},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-2952.8, 486.07, 14.67), rotation = 137.3}
            }
        }
    },
    {
        name = "Route 66",
        coords = vector3(1175.542, 2710.861, 37.07689),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("v_ilev_gb_vauldr"),
                coords = vector3(1175.62, 2712.906, 38.18807),
                rotation = 90.0
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(1172.49, 2711.1, 37.06), rotation = 340.17},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(1174.88, 2716.49, 37.06), rotation = 151.18},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(1171.52, 2716.35, 37.06), rotation = 88.24}
            }
        }
    },
    {
        name = "Paleto",
        coords = vector3(-103.9671, 6479.497, 30.5155),
        radius = 2.0,
        robbery = {
            vault = {
                hackModel = GetHashKey("v_corp_bk_secpanel"),
                doorModel = GetHashKey("v_ilev_gb_vauldr"),
                coords = vector3(-104.91, 6477.57, 31.62672),
                rotation = -45.0
            },
            cashLocations = {
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-103.15, 6482.4, 30.49), rotation = 130.03},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-106.77, 6478.42, 30.49), rotation = 311.42},
                {model = GetHashKey("hei_prop_hei_cash_trolly_01"), empty = GetHashKey("hei_prop_hei_cash_trolly_03"), coords = vector3(-102.83, 6478.4, 30.49), rotation = 52.0}
            }
        }
    }
}