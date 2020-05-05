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
    "0.15", "0.3", "0.6", "1.0", "2.0", "3.0", "4.0", "6.0", "10.0", "20.0", "40.0", "100.0", "500.0", "auto"
]

const UNIT_PRICE_RANGE = {
    1: "CU: 10 | SU: 6 | NU: 0.4",
    2: "CU: 12 | SU: 8 | NU: 0.5",
    3: "CU: 15 | SU: 10 | NU: 0.5",
    4: "CU: 20 | SU: 15 | NU: 0.8",
}

const ajax = webix.ajax().headers({ "content-type": "application/json" });

function getData() {
    const form = webix.$$("simulator_form");
    let values = form.getValues();

    values["growth"] = GROWTH[values["growth"]]
    values["token_price"] = TOKEN_PRICE[values["token_price"]]

    webix.extend(form, webix.ProgressBar);
    form.showProgress();


    ajax.post("/api/simulator", values).then((data) => {
        form.hideProgress();

        const name = data.json().name;
        window.location.href = `/${name}`;
        debugger
    }).catch((error) => {
        form.hideProgress();

        if (error.status == 404) {
            webix.message({
                type: "error",
                text: JSON.parse(error.responseText).message
            });
        }

    });
}

function reset() {
    const form = webix.$$("simulator_form");
    form.setValues({
        hardware_type: "amd",
        growth: 0,
        token_price: 0,
        unit_price_range: 1
    });
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
                    ],
                    labelWidth: 150,
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
                    labelWidth: 150,
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
                    labelWidth: 150,
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
                    labelWidth: 150,
                },
                {
                    margin: 5,
                    cols: [
                        {
                            view: "button",
                            value: "Get data",
                            css: "webix_primary",
                            click: getData
                        },
                        {
                            view: "button",
                            value: "Reset",
                            click: reset
                        }
                    ]
                }
            ]
        },
    ]
});
