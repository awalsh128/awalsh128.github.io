---
layout: posts
title: Converting thermocouple voltages to temperature.
date: '2012-07-25T13:23:00.000-07:00'
author: awalsh128
tags:
- data acquisition
modified_time: '2012-08-01T16:20:36.425-07:00'
thumbnail: http://1.bp.blogspot.com/-gaacEByTnvA/UBBLzb9lfWI/AAAAAAAAA8k/vigwBYw-Pas/s72-c/ktype.gif
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-2633754900089192672
blogger_orig_url: https://awalsh128.blogspot.com/2012/07/converting-thermocouple-voltages-to.html
---

### Background

Unlike most sensors used in data acquisition, thermocouples do not have
a linear mapping between their voltage and celcius values. This means
that instead of factoring some scalar value against the data, in order
to scale it to engineering units (eg. volts to acceleration), an
[experimentally derived
equation](http://en.wikipedia.org/wiki/Thermocouple#Voltage.E2.80.93temperature_relationship)
must be created to approximate the temperature at specific voltages.
This non-linearity is primarily due to the materials being used to
discover the temperature difference.

The science and engineering behind thermocouples goes beyond the scope
of this post but more information can be found below:

-   [Wikipedia: Thermoelectric
    Effect](http://en.wikipedia.org/wiki/Thermoelectric_effect)
-   [Wikipedia: Thermocouple](http://en.wikipedia.org/wiki/Thermocouple)
-   [Reference
    Temperatures](http://www.omega.com/temperature/z/pdf/z021-032.pdf)
-   [Simple Demonstration of the Seebeck
    Effect](http://www.scienceeducationreview.com/open_access/molki-seebeck.pdf)

### K-Type Thermocouples

One of the most general purpose thermocouple types used in data
acquisition are [K types](http://en.wikipedia.org/wiki/Thermocouple#K)
since their are relatively inexpensive to make. This will also be the
thermocouple that I will focus on.

Luckily, [NIST](http://www.nist.gov) provides a [table of discrete
values](http://srdata.nist.gov/its90/main/), correlating voltages to
celcius and vice-versa. In addition, they also provide the exact
polynomial equation to use [underneath the given
tables](http://srdata.nist.gov/its90/download/type_k.tab), depending on
the voltage range the value falls in. Following is the exact functions
to do the conversion for K-type thermocouples.

Voltage To Celcius
------------------

Given some ordered set of coefficients, *D*, and a voltages value, *v*,
let the voltage to celcius conversion be defined as a function of *v* as
follows.

::: {.separator style="clear: both; text-align: center;"}
[![](http://1.bp.blogspot.com/-gaacEByTnvA/UBBLzb9lfWI/AAAAAAAAA8k/vigwBYw-Pas/s400/ktype.gif){width="56"
height="56"}](http://1.bp.blogspot.com/-gaacEByTnvA/UBBLzb9lfWI/AAAAAAAAA8k/vigwBYw-Pas/s1600/ktype.gif)
:::

*D* is dependent on the voltage value being evaluated:

-   values greater than 206.44 mV will have *D = {-131.8058, 48.30222,
    -1.646031, 0.05464731, -0.0009650715, 0.000008802193,
    -0.0000000311081, 0.0, 0.0, 0.0 }*;
-   values geater than 0.0 V will have *D = { 0.0, 25.08355, 0.07860106,
    -0.2503131, 0.0831527, -0.01228034, 0.0009804036, -0.0000441303,
    0.000001057734,-0.00000001052755}*;
-   and values less than 0.0 V will have *D = { 0.0, 25.173462,
    -1.1662878, -1.0833638, -0.8977354, -0.37342377, -0.086632643,
    -0.010450598, -0.00051920577, 0.0 }*.

Celcius To Voltage
------------------

Given some ordered set of coefficients, *C*, an ordered set of
exponentials, *A*, and a celcius value, *x*, let the celcius to voltage
conversion be defined as a function of *x* as follows.

::: {.separator style="clear: both; text-align: center;"}
[![](http://4.bp.blogspot.com/-KxsCdsIpbCg/UBBQYlp3s5I/AAAAAAAAA80/hdsuZgJaktQ/s400/ktype-ctov.gif){width="182"
height="56"}](http://4.bp.blogspot.com/-KxsCdsIpbCg/UBBQYlp3s5I/AAAAAAAAA80/hdsuZgJaktQ/s1600/ktype-ctov.gif)
:::

*C* is dependent on the celius value being evaluated:

-   positive and zero values will have *C = { -0.017600413686,
    0.038921204975, 0.000018558770032, -0.000000099457592874,
    0.00000000031840945719, -0.00000000000056072844889,
    0.00000000000000056075059059, -3.2020720003E-19, 9.7151147152E-23,
    -1.2104721275E-26}*;
-   negative values will have *C = { 0.0, 0.039450128025,
    0.000023622373598, -0.00000032858906784, -0.0000000049904828777,
    -0.000000000067509059173, -0.00000000000057410327428,
    -0.0000000000000031088872894, -1.0451609365E-17, -1.9889266878E-20,
    -1.6322697486E-23}*;

*A* is a fixed ordered set of exponentials; *A = {0.1185976,
-0.0001183432, 126.9686}*.

### Performance

Since the polynomial equation\'s number of terms are bounded by a
constant (ie. *\|D\|* or *\|C\|*) the performance hit will be a constant
factor to the number of voltage or celcius values to calculate. Also,
temperature is sampled at a very low rate, yielding small data sets that
usually have redundant values in them. Further optimization can be made
by caching previous computations and reusing their results if the same
voltage or celcius value is encountered again.

### The Code

``` csharp
private static double[] _thermocoupleCoefficientsTypeKneg = {
 0.0,
 0.039450128025,
 2.3622373598E-05,
 -3.2858906784E-07,
 -4.9904828777E-09,
 -6.7509059173E-11,
 -5.7410327428E-13,
 -3.1088872894E-15,
 -1.0451609365E-17,
 -1.9889266878E-20,
 -1.6322697486E-23
};
private static double[] _thermocoupleCoefficientsTypeKpos = {
 -0.017600413686,
 0.038921204975,
 1.8558770032E-05,
 -9.9457592874E-08,
 3.1840945719E-10,
 -5.6072844889E-13,
 5.6075059059E-16,
 -3.2020720003E-19,
 9.7151147152E-23,
 -1.2104721275E-26
};
private static double[] _thermocoupleExponentialsTypeK = {
 0.1185976,
 -0.0001183432,
 126.9686
};
/// 
/// Type K thermocouple inverse coefficient values for voltage to celcius conversions.
/// 
/// Valid values for -200C - 0C / -5.891mV - 0mV.
private static double[] _thermocoupleInverseCoefficientsTypeK0 = {
 0.0,
 25.173462,
 -1.1662878,
 -1.0833638,
 -0.8977354,
 -0.37342377,
 -0.086632643,
 -0.010450598,
 -0.00051920577,
 0.0
};
/// 
/// Type K thermocouple inverse coefficient values for voltage to celcius conversions.
/// 
/// Valid values for 0C - 500C / 0mV - 20.644mV.
private static double[] _thermocoupleInverseCoefficientsTypeK1 = {
 0.0,
 25.08355,
 0.07860106,
 -0.2503131,
 0.0831527,
 -0.01228034,
 0.0009804036,
 -4.41303E-05,
 1.057734E-06,
 -1.052755E-08
};
/// 
/// Type K thermocouple inverse coefficient values for voltage to celcius conversions.
/// 
/// Valid values for 500C - 1372C / 20.644mV - 54.886mV.
private static double[] _thermocoupleInverseCoefficientsTypeK2 = {
 -131.8058,
 48.30222,
 -1.646031,
 0.05464731,
 -0.0009650715,
 8.802193E-06,
 -3.11081E-08,
 0.0,
 0.0,
 0.0
};


public static double CelciusToVoltageTypeK(double value)
{
 double[] a = _thermocoupleExponentialsTypeK;
 double[] c = null;
 double result = 0.0;
 if ((value >= 0.0)) {
  c = _thermocoupleCoefficientsTypeKpos;
 } else {
  c = _thermocoupleCoefficientsTypeKneg;
 }
 for (int index = 0; index <= c.Length - 1; index++) {
  result += (c[index] * Math.Pow(value, index)) + (a[0] * Math.Exp(a[1] * Math.Pow(value - a[2], 2)));
 }
 return result;
}

public static double VoltageToCelciusTypeK(double value)
{
 double[] d = null;
 double result = 0.0;
 if ((value > 0.020644)) {
  d = _thermocoupleInverseCoefficientsTypeK2;
 } else if ((value >= 0.0)) {
  d = _thermocoupleInverseCoefficientsTypeK1;
 } else {
  d = _thermocoupleInverseCoefficientsTypeK0;
 }
 for (int index = 0; index <= d.Length - 1; index++) {
  result += d[index] * Math.Pow(value, index);
 }
 return result;
}
```
