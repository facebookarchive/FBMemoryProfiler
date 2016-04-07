# Example Usage of Memory Profiler

This is a very simple project. Is fetches a list of [Facebook Open Source Projects](https://github.com/facebook) and presents them in table view. On click it loads up project's Github page in UIWebView.

## How to run

To run this project you have to bootstrap carthage dependencies from root of the repository:

```carthage bootstrap --configuration Debug```

## Presentation

This app shows how you can use `FBMemoryProfiler` in your project. In this example we are introducing retain cycle on purpose and we are showing it in the tool.

<img src="Images/Example2.gif" width=450/>
