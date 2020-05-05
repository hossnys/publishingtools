const GROWTH = [
    50000,
    100000,
    200000,
    600000,
    1000000,
    2000000,
    4000000,
    10000000,
    20000000
]

const TOKEN_PRICE = [
    0.15, 0.3, 0.6, 1, 2, 3, 4, 6, 10, 20, 40, 100, 500, "auto"
]

const UNIT_PRICE_RANGE = {
    1: "CU: 10, SU: 6, NU: 0.4",
    2: "CU: 12 SU: 8 NU: 0.5",
    3: "CU: 15 SU: 10 NU: 0.5",
    4: "CU: 20 SU: 15 NU: 0.8",
}

webix.ui({
    rows: [
        {
            view: "template",
            type: "header",
            template: "Simulator"
        },
        {
            view: "form",
            id: "simulator_form",
            width: 300,
            elements: [
                {
                    id: "hardware_type",
                    name: "hardware_type",
                    view: "richselect",
                    label: "Hardware",
                    value: "amd",
                    yCount: 1,
                    options: [
                        {
                            id: "amd",
                            value: "AMD"
                        }
                    ]
                },
                {
                    id: "growth",
                    view: "slider",
                    name: "growth",
                    label: "Growth",
                    value: 0,
                    step: 1,
                    min: 0,
                    max: GROWTH.length - 1,
                    title: function () {
                        return GROWTH[this.value];
                    },
                },
                {
                    id: "token_price",
                    view: "slider",
                    name: "token_price",
                    label: "Token price",
                    value: 0,
                    step: 1,
                    min: 0,
                    max: TOKEN_PRICE.length - 1,
                    title: function () {
                        return TOKEN_PRICE[this.value];
                    },
                },
                {
                    id: "unit_price_range",
                    view: "slider",
                    name: "unit_price_range",
                    label: "Unit price range",
                    value: 1,
                    step: 1,
                    min: 1,
                    max: Object.keys(UNIT_PRICE_RANGE).length,
                    title: function () {
                        return UNIT_PRICE_RANGE[this.value];
                    },
                },
                {
                    margin: 5,
                    cols: [
                        {
                            view: "button",
                            value: "Submit",
                            css: "webix_primary"
                        },
                        {
                            view: "button",
                            value: "Clear"
                        }
                    ]
                }
            ]
        },
        // {
        //     view: "datatable",
        //     autoConfig: true,
        //     data: {
        //         title: "My Fair Lady",
        //         year: 1964,
        //         votes: 533848,
        //         rating: 8.9,
        //         rank: 5
        //     }
        // }
    ]
});
