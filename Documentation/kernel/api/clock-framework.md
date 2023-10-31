# 时钟框架

时钟框架定义了编程接口，以支持系统时钟树的软件管理。该框架广泛应用于片上系统(SOC)平台，以支持电源管理和可能需要自定义时钟速率的各种设备。请注意，这些“时钟”与计时或实时时钟(rtc)无关，它们都有单独的框架。这些struct clock实例可用于管理例如96 MHz信号，该信号用于将位移进和移出外设或总线，或者触发系统硬件中的同步状态机转换。

电源管理由显式软件时钟门控支持:未使用的时钟被禁用，因此系统不会浪费功率来改变不活跃使用的晶体管的状态。在某些系统上，这可能是由硬件时钟门控支持的，其中时钟是门控的，而不是在软件中禁用。有电源但没有时钟的芯片部分可能能够保持它们的最后状态。这种低功耗状态通常被称为保持模式。这种模式仍然会产生漏电流，特别是对于更精细的电路几何形状，但对于CMOS电路，功率主要用于时钟状态变化。

电源感知驱动程序只有在其管理的设备处于活跃使用状态时才启用时钟。此外，系统睡眠状态通常根据哪些时钟域处于活动状态而有所不同:虽然“待机”状态可能允许从几个活动域唤醒，但“mem”(挂起到ram)状态可能需要更大规模地关闭来自更高速度锁相环和振荡器的时钟，从而限制了可能的唤醒事件源的数量。驱动程序的suspend方法可能需要知道目标睡眠状态上的系统特定时钟约束。

一些平台支持可编程时钟生成器。这些可用于各种外部芯片，如其他cpu、多媒体编解码器和对接口时钟有严格要求的设备。

## clk_notifier

定义：
```c
struct clk_notifier 
{
  struct clk                      *clk;
  struct srcu_notifier_head       notifier_head;
  struct list_head                node;
};
```

## clk_notifier_data

定义：
```c
struct clk_notifier_data 
{
  struct clk              *clk;
  unsigned long           old_rate;
  unsigned long           new_rate;
};
```

## clk_bulk_data

定义：
```c
struct clk_bulk_data 
{
  const char              *id;
  struct clk              *clk;
};
```

## clk_notifier_register

函数签名：
```c
int clk_notifier_register(struct clk *clk, struct notifier_block *nb);
```

## clk_notifier_unregister

函数签名：
```c
int clk_notifier_unregister(struct clk *clk, struct notifier_block *nb);
```

## devm_clk_notifier_register

函数签名：
```c
int devm_clk_notifier_register(struct device *dev, struct clk *clk, struct notifier_block *nb);
```

## clk_get_accuracy

函数签名：
```c
long clk_get_accuracy(struct clk *clk);
```

## clk_set_phase

函数签名：
```c
int clk_set_phase(struct clk *clk, int degrees);
```

## clk_get_phase

函数签名：
```c
int clk_get_phase(struct clk *clk);
```

## clk_set_duty_cycle

函数签名：
```c
int clk_set_duty_cycle(struct clk *clk, unsigned int num, unsigned int den);
```

## clk_get_scaled_duty_cycle

函数签名：
```c
int clk_get_scaled_duty_cycle(struct clk *clk, unsigned int scale);
```

## clk_is_match

函数签名：
```c
bool clk_is_match(const struct clk *p, const struct clk *q);
```

## clk_rate_exclusive_get

函数签名：
```c
int clk_rate_exclusive_get(struct clk *clk);
```

## clk_rate_exclusive_put

函数签名：
```c
void clk_rate_exclusive_put(struct clk *clk);
```

## clk_prepare

函数签名：
```c
int clk_prepare(struct clk *clk);
```

## clk_is_enable_when_prepared

函数签名：
```c
bool clk_is_enabled_when_prepared(struct clk *clk);
```

## clk_unprepare

函数签名：
```c
void clk_unprepare(struct clk *clk);
```

## clk_get

函数签名：
```c
struct clk *clk_get(struct device *dev, const char *id);
```

## clk_bulk_get

函数签名：
```c
int clk_bulk_get(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

## clk_bulk_get_all

函数签名：
```c
int clk_bulk_get_all(struct device *dev, struct clk_bulk_data **clks);
```

## clk_bulk_get_optional

函数签名：
```c
int clk_bulk_get_optional(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

## devm_clk_bulk_get

函数签名：
```c
int devm_clk_bulk_get(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

## devm_clk_bulk_get_optional

函数签名：
```c
int devm_clk_bulk_get_optional(struct device *dev, int num_clks, struct clk_bulk_data *clks);
```

## devm_clk_bulk_get_all

函数签名：
```c
int devm_clk_bulk_get_all(struct device *dev, struct clk_bulk_data **clks);
```

## devm_clk_get

函数签名：
```c
struct clk *devm_clk_get(struct device *dev, const char *id);
```

## devm_clk_get_prepared

函数签名：
```c
struct clk *devm_clk_get_prepared(struct device *dev, const char *id);
```

## devm_clk_get_enabled

函数签名：
```c
struct clk *devm_clk_get_enabled(struct device *dev, const char *id);
```

## devm_clk_get_optional

函数签名：
```c
struct clk *devm_clk_get_optional(struct device *dev, const char *id);
```

## devm_clk_get_optional_prepared

函数签名：
```c
struct clk *devm_clk_get_optional_prepared(struct device *dev, const char *id);
```

## devm_clk_get_optional_enabled

函数签名：
```c
struct clk *devm_clk_get_optional_enabled(struct device *dev, const char *id);
```

## devm_get_clk_from_child

函数签名：
```c
struct clk *devm_get_clk_from_child(struct device *dev, struct device_node *np, const char *con_id);
```

## clk_enable

函数签名：
```c
int clk_enable(struct clk *clk);
```

## clk_bulk_enable

函数签名：
```c
int clk_bulk_enable(int num_clks, const struct clk_bulk_data *clks);
```

## clk_disable

函数签名：
```c
void clk_disable(struct clk *clk);
```

## clk_bulk_disable

函数签名：
```c
void clk_bulk_disable(int num_clks, const struct clk_bulk_data *clks);
```

## clk_get_rate

函数签名：
```c
unsigned long clk_get_rate(struct clk *clk);
```

## clk_put

函数签名：
```c
void clk_put(struct clk *clk);
```

## clk_bulk_put

函数签名：
```c
void clk_bulk_put(int num_clks, struct clk_bulk_data *clks);
```

## clk_bulk_put_all

函数签名：
```c
void clk_bulk_put_all(int num_clks, struct clk_bulk_data *clks);
```

## devm_clk_put

函数签名：
```c
void devm_clk_put(struct device *dev, struct clk *clk);
```

## clk_round_rate

函数签名：
```c
long clk_round_rate(struct clk *clk, unsigned long rate);
```

## clk_set_rate

函数签名：
```c
int clk_set_rate(struct clk *clk, unsigned long rate);
```

## clk_set_rate_exclusive

函数签名：
```c
int clk_set_rate_exclusive(struct clk *clk, unsigned long rate);
```

## clk_has_parent

函数签名：
```c
bool clk_has_parent(const struct clk *clk, const struct clk *parent);
```

## clk_set_rate_range

函数签名：
```c
int clk_set_rate_range(struct clk *clk, unsigned long min, unsigned long max);
```

## clk_set_min_rate

函数签名：
```c
int clk_set_min_rate(struct clk *clk, unsigned long rate)
```

## clk_set_max_rate

函数签名：
```c
int clk_set_max_rate(struct clk *clk, unsigned long rate);
```

## clk_set_parent

函数签名：
```c
int clk_set_parent(struct clk *clk, struct clk *parent);
```

## clk_get_parent

函数签名：
```c
struct clk *clk_get_parent(struct clk *clk);
```

## clk_get_sys

函数签名：
```c
struct clk *clk_get_sys(const char *dev_id, const char *con_id);
```

## clk_save_context

函数签名：
```c
int clk_save_context(void);
```

## clk_restore_context

函数签名：
```c
void clk_restore_context(void);
```

## clk_drop_range

函数签名：
```c
int clk_drop_range(struct clk *clk);
```

## clk_get_optional

函数签名：
```c
struct clk *clk_get_optional(struct device *dev, const char *id);
```


