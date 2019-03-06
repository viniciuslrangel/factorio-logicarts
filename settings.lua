data:extend({
  {
    type = "double-setting",
    name = "logicarts-fuel-threshold",
    order = "a",
    setting_type = "runtime-global",
    default_value = 0.25,
    minimum_value = 0.1,
    maximum_value = 1.0,
  },
  {
    type = "bool-setting",
    name = "logicarts-grass-wearing",
    order = "b",
    setting_type = "runtime-global",
    default_value = true,
  },
  {
    type = "int-setting",
    name = "logicarts-deploy-seconds",
    order = "c",
    setting_type = "runtime-global",
    default_value = 3,
    minimum_value = 1,
    maximum_value = 60,
  },
})
