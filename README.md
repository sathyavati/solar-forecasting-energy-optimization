# Solar Power Forecasting & Smart Energy Optimization

End-to-end analysis of two utility-scale solar plants in India: 

**MySQL** data pipeline → data-quality audit → EDA → **1-hour-ahead generation forecasting** (benchmarked against naive baselines) → forecast-driven **battery storage simulation**.

**Data:** [Kaggle - Solar Power Generation Data](https://www.kaggle.com/datasets/anikannal/solar-power-generation-data)

## Key results
 
| What | Result |
|---|---|
| 1-hour-ahead forecast (Random Forest + lag features) | MAE 1,370 kW, R² 0.88 i.e **40% lower error than persistence baseline** |
| LSTM comparison (same split, same metrics) | MAE 1,795 kW, R² 0.84 which beats all baselines but loses to RF on only 34 days of data |
| Faulty equipment found via SQL audit | 2 inverters at ~10% underperformance with 42 zero-output-in-full-sun events; separate 9-day, 4-inverter outage at Plant 2 |
| Battery simulation (20 MWh, 8 MW load, test week) | **19% reduction in grid energy** (~₹6 lakh/week at ₹4/kWh); 313 MWh curtailed ⇒ battery undersized |
| Plant comparison | Plant 2 produced ~21% less energy than Plant 1 under near-identical weather |
| Physics check | Module temperature vs output-per-unit-irradiation: r = −0.52 (heat reduces panel efficiency) |

## Forecast quality
 
1-hour-ahead model predictions vs actual generation on unseen test days. The persistence baseline is structurally "one hour late" on every ramp; the Random Forest anticipates them:
