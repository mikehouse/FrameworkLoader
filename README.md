

## FrameworkLoader

### Description 

- FrameworkLoader is a simple utitlity which helps to download \*.framework bundles from network and save them on iOS/OSX/TVOS/WATCHOS devices.
- Cool stuff for Swift reflection, check that out.

### Env

- Swift 2.2
- Xcode 7.3

### How to use

#### Prepare a server side

- prepare a framework bundle:


```
zip -qr MyFramework.zip MyFramework.framework/
```

- form a url of some abstract server as **http://localhost:8080/frameworks/MyFramework.zip**

#### Client code

- Download and run the framework bundle on client:

```
import FrameworkLoader

let url = NSURL(string: "http://localhost:8080/frameworks/MyFramework.zip")!;
let request = NSURLRequest(URL: url)
Loader(request: request).fetchAsync { (fetchError, loader) in
    if let er = fetchError {
        // something went wrong, it might be:
        // 1. server error
        // 2. invalid zip file
        // 3. zip file does not have any framework bundle inside
        print(er)
    } else {
        // ok, zip file got loaded and unzipped, now we can try to load it like a bundle
        do {
            let bundle = try loader.tryLoad()
            
            // want to show controllers from loaded bundle
            
            let navigationController = UINavigationController(nibName: "MyNavViewController", bundle: bundle.bundle)
            let rootController = UIViewController(nibName: "MyRootViewController", bundle: bundle.bundle)
            navigationController.viewControllers = [rootController]
            
            self.presentViewController(navigationController, animated: true)
            
            // or call method on runtime!
            
            guard let myCustomAlertClass = bundle.loadClass("MyCustomAlertClass") else { return }
            
            // call method without args
            let method = try! Reflection.instanceMethod(NSSelectorFromString("showAlert"), cls: myCustomAlertClass)
            method() // showAlert
            
            // call method with one arg
            let methodWithArg = try! Reflection.instanceMethodWithArg(NSSelectorFromString("showAlertWIthTitle:"), cls: myCustomAlertClass)
            methodWithArg("Hi there!") // show alert with title 'Hi there!'
            
        } catch {
            // reasons which might cause this error:
            // 1. invalid framework bundle structure
            // 2. invalid architecture, that is as example the client is iphone5s (arm64) but framework bundle is for OSX (x86_64)
            print(error)
        }
    }
}
```

- load previously loaded framework bundle:

```
import FrameworkLoader

guard let bundle = Bundle(name: "MyFramework") else { return }

// want to show controllers from loaded bundle

let navigationController = UINavigationController(nibName: "MyNavViewController", bundle: bundle.bundle)
let rootController = UIViewController(nibName: "MyRootViewController", bundle: bundle.bundle)
navigationController.viewControllers = [rootController]

self.presentViewController(navigationController, animated: true)

// or call method on runtime!

guard let myCustomAlertClass = bundle.loadClass("MyCustomAlertClass") else { return }

// call method without args
let method = try! Reflection.instanceMethod(NSSelectorFromString("showAlert"), cls: myCustomAlertClass)
method() // showAlert

// call method with one arg
let methodWithArg = try! Reflection.instanceMethodWithArg(NSSelectorFromString("showAlertWIthTitle:"), cls: myCustomAlertClass)
methodWithArg("Hi there!") // show alert with title 'Hi there!'

```


### Integration

- add to Podfile:

```
pod 'FrameworkLoader', :git => ''
```

- after run "pod update"

======
