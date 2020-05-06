const HARDWARE_TYPES = [
    "amd"
]

const GROWTHS = [
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

const TOKEN_PRICES = [
    "0.15", "0.3", "0.6", "1.0", "2.0", "3.0", "4.0", "6.0", "10.0", "20.0", "40.0", "100.0", "500.0", "auto"
]

const UNIT_PRICE_RANGES = [
    1, 2, 3, 4
]

const UNIT_PRICE_RANGE_LABELS = {
    1: "CU: 10 | SU: 6 | NU: 0.4",
    2: "CU: 12 | SU: 8 | NU: 0.5",
    3: "CU: 15 | SU: 10 | NU: 0.5",
    4: "CU: 20 | SU: 15 | NU: 0.8",
}

const ajax = webix.ajax().headers({ "content-type": "application/json" });

const response = webix.ajax().sync().get("/api/simulator/options");
let availableOptions = JSON.parse(response.responseText)
availableOptions.hardware_types = availableOptions.hardware_types.length ? availableOptions.hardware_types : HARDWARE_TYPES
availableOptions.growths = availableOptions.growths.length ? availableOptions.growths : GROWTHS
availableOptions.token_prices = availableOptions.token_prices.length ? availableOptions.token_prices : TOKEN_PRICES
availableOptions.unit_price_ranges = availableOptions.unit_price_ranges.length ? availableOptions.unit_price_ranges : UNIT_PRICE_RANGES


availableOptions.hardware_types.sort()
availableOptions.growths.sort()
availableOptions.token_prices.sort()
availableOptions.unit_price_ranges.sort()

const unitPriceOptions = availableOptions.unit_price_ranges.map((key) => {
    return {
        id: key,
        value: key + ' - ' + UNIT_PRICE_RANGE_LABELS[key]
    }
});

function getData() {
    const form = webix.$$("simulator_form");
    let values = form.getValues();

    values["growth"] = availableOptions.growths[values["growth"]]
    values["token_price"] = availableOptions.token_prices[values["token_price"]]

    webix.extend(form, webix.ProgressBar);
    form.showProgress();


    ajax.post("/api/simulator", values).then((data) => {
        form.hideProgress();

        const name = data.json().name;
        window.location.href = `/${name}`;
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
        hardware_type: availableOptions.hardware_types[0],
        growth: 0, // first option
        token_price: 0, // first option
        unit_price_range: unitPriceOptions[0].id
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
                    value: availableOptions.hardware_types[0],
                    yCount: 1,
                    options: availableOptions.hardware_types,
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
                    max: availableOptions.growths.length - 1,
                    title: function () {
                        return availableOptions.growths[this.value];
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
                    max: availableOptions.token_prices.length - 1,
                    title: function () {
                        return availableOptions.token_prices[this.value];
                    },
                    labelWidth: 150,
                },
                {
                    id: "unit_price_range",
                    name: "unit_price_range",
                    view: "richselect",
                    label: "Unit price range",
                    value: unitPriceOptions[0].id,
                    yCount: Object.keys(unitPriceOptions.length),
                    options: unitPriceOptions,
                    labelWidth: 150,
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
