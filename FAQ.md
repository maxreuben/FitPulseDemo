# FAQs

* _Does the SDK work offline?_ <br />
No, it doesn't as the facial data is sent to Physiology API to perform analysis and fetch the pulse and breathing rates.

* _How do I add a real-time chart?_ <br />
Use the ContunuousPlotView() function in SmartSpectraSDK to show real-time pulse and breathing rate data as a chart

* _How do I reduce CPU usage on older iPhones?_ <br />
The frame rate and camera resolution can be reduced on older devices. The sampling rate of the data can be reduced and frames can be skipped. The UI updates can be batched so that the graph isn't redrawn for every single data point but for batches of data points, but then the feed will no longer be real-time. Max, Min and Average updations can be throttled as with Combine.throttle .
