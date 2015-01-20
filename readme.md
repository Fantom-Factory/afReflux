#Reflux v0.0.0
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v0.0.0](http://img.shields.io/badge/pod-v0.0.0-yellow.svg)](http://www.fantomfactory.org/pods/afReflux)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

One the things that originally enticed me to Fantom was FWT. I already had a soft spot for SWT becasue it was far simpler than Swing, and Fantom's FWT wrapper simplified SWT exponentially!

I also really liked the idea of `flux`, creating applications based on a browser paradigm and the ability to represent database entities with URIs. With `Views` and `SideBars` it was also kinda inspired by Eclipse's RCP. In all, it was a neat idea!

Only I kept finding the `flux` implementation a bit, um, *klunky*. It was hard to customise, configuration by index props seemed like a poor man's IoC, and installing an app on a fresh Fantom install required lots of annoying config file changes.

So, fuelled by a desire to create a customisable, voice driven explorer application, I tinkered with a new code base that's now evolved to `Reflux`.

## Overview

`Reflux` is a framework for creating a simple FWT desktop applications.

Modeled after an internet browser, Reflux lets you explore and edit resources using URIs. It expands upon Fantom's FWT by adding:

- **An IoC container** - Relflux applications are IoC applications.
- **Events** - An application wide eventing mechanism.
- **Customisation** - All aspects of a Reflux application may be customised.
- **Context sensitive commands** - Global commands may be enabled / disabled.
- **Browser session** - A consistent means to store session data.
- **New FWT widgits** - Fancy tabs and a working web browser.

Reflux was inspired by Fantom's core `flux` library.

> Reflux :: Flux -> Reloaded.

## Install

Install `Reflux` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afReflux

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afReflux 0.0"]

## Documentation

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afReflux/).

## Quick Start

## Usage

`Reflux` takes the internet browser strategy of labelling everything with a URI. Be it a file, an internet resource, or a database entity - if it can be identified by a URI then it may presented and edited in Reflux.

A Reflux application is made up of:

- Menu bar
- Tool bar
- Global commands
- Panels
- Views

![Screenshot of the Alien-Factory Explorer application](afReflux.afExplorer.png)

URIs are typed into the address bar. The typed URI is then resolved to a `Resource`. Resource objects hold meta data that describe how it should be displayed / interacted with. Views are used to view and / or edit resources. Panels are extra tabs that show arbitary data; for example, the [ErrorsPanel](http://repo.status302.com/doc/afReflux/ErrorsPanel.html) lists any errors incurred by the application.

The menu and tool bars are customisable via IoC contributions. Global commands wrap standard FWT commands to make them context sensitive; for example, the Save global command is only enabled when the current view is dirty.

Note that Reflux itself is just a toolkit. See the [Alien-Factory Explorer](http://www.fantomfactory.org/pods/afExplorer) application for a concrete example of Reflux use.

## Panels

[Panels](http://repo.status302.com/doc/afReflux/Panel.html) are widget panes that decorate the edges of the main window. Only one instance of each panel type may exist. They are typically created at application startup and live until the application shuts down.

To create a custom panel, first create a class that extends [Panel](http://repo.status302.com/doc/afReflux/Panel.html). Panels must set the `content` field in order to display anything. This example just sets its FWT content to a yellow label:

```
class MyPanel : Panel {
    new make(|This| in) : super(in) { 
        content = Label() {
            it.text = "Hello Mum!"
            it.bg   = Color.yellow
        }
    }
}
```

Note that the Panel's ctor must take an `it-block` parameter and pass it up to the superclass to be executed. This is so IoC can inject all those lovely dependencies. Now contribute an instance of the panel to the `Panels` service in your `AppModule`:

```
class AppModule {
    @Contribute { serviceType=Panels# }
    static Void contributePanels(Configuration config) {
        myPanel := config.autobuild(MyPanel#)
        config.add(myPanel)
    }
}
```

Panels need to be *autobuilt* so IoC injects all the depdencies (via that it-block ctor parameter).

Panels are automatically added to the `View -> Panels` menu. If the panel does not set a name it defaults the the Panel's type, minus any `Panel` suffix. When displayed, our simple panel should look like:

![Screenshot of Panel Example](afReflux.panelExample.png)

Note that Panels are not displayed by default; but the user's display settings are saved from one session to the next. To force the user to always start with the panel displayed, show it progamatically on application startup:

```
Reflux.start("Example", [AppModule#]) |Reflux reflux, Window window| {
    reflux.showPanel(MyPanel#)
} 
```

Panels contain several callback methods that are invoked at different times of its lifecycle. These are:

- `onShow()` - called when it's added to the tab pane.
- `onActivate()` - called when it becomes the active tab.
- `onModify()` - called when panel details are modified, such as the name or icon.
- `onDeactivate()` - called when some other tab becomes active.
- `onHide()` - called when it is removed from the tab pane.
- `refresh()` - called when the panel `isShowing` and the refresh button is clicked.

Panel's are

Panels are automatically added to the `EventHub` - see [Eventing](http://repo.status302.com/doc/afReflux/#eventing.html) for details.

## Views

[Views](http://repo.status302.com/doc/afReflux/View.html) are `Panels` that are associated with an (editable) resource. They are displayed in the centre of the Window.

Custom views must extends [View](http://repo.status302.com/doc/afReflux/View.html), which in turn extends `Panel`. Like panels, views must set the `content` field to display anything. This example view just displays the resource name in a green box:

```
class MyView : View {
    Label label

    new make(|This| in) : super(in) { 
        content = label = Label() {
            it.bg = Color.green
        }
    }
    
    override Void load(Resource resource) {
        super.load(resource)
        label.text = "Resource Name: ${resource.name}"
    }
}
```

Because a View is associated with a resource, it has a few more callbacks:

- `load()` - called when the view should display a resource.
- `save()` - called when the save button is clicked.
- `refresh()` - called when the refresh button is clicked.
- `confirmClose()` - called when the view is being closed.

Resources decide how they want to be displayed, so to display our view we need to create a concrete Resource implementation...

## Resolving URIs

Lets take this simple resource object:

```
class MyResource : Resource {
    override Uri    uri
    override Str    name
    override Image? icon

    new make(Uri uri, |This|in) : super.make(in) { 
        this.uri  = uri
        this.name = uri.name
        this.icon = Image("fan://icons/x16/database.png")
    }

    override Type[] viewTypes() {
        [MyView#]
    }    
}
```

It holds it's name, has a *database* icon and the `viewTypes()` method says it should be represented by the `MyView` class.

Should `viewTypes()` return more than one type, the user may cycle between them using drop down in the address bar or an `F12` shortcut. This useful for toggling between view and edit modes.

It is the job of [UriResolvers](http://repo.status302.com/doc/afReflux/UriResolver.html) to convert URI strings, as entered in the address bar, into resource instances. The following URI resolver will convert any URI with the scheme `example:` into a `MyResource` object:

```
class MyResolver : UriResolver {
    @Inject Registry registry
    
    new make(|This|in) { in(this) }
    
    override Resource? resolve(Str uri) {
        uri.toUri.scheme == "example"
            ? registry.autobuild(MyResource#, [uri.toUri])
            : null
    }
}
```

To use `MyResolver` it must be contributed to the `UriResolvers` service in the `AppModule`:

```
@Contribute { serviceType=UriResolvers# }
static Void contributeUriResolvers(Configuration config) {
    config["myResolver"] = config.autobuild(MyResolver#)
}
```

When `example:foo-bar` is entered into the address bar, the following should happen:

- `MyResolver` resolves `example:foo-bar` and builds a `MyResource` instance.
- `MyResource` returns `MyView` as a view type.
- `MyView` is created and asked to load the `MyResource`.

And this should be displayed:

![Screenshot of View Example](afReflux.viewExample.png)

## Menu Bar

Reflux comes with a pre-configured menu bar which is suitable for most applications. However it may be altered via IoC contributions.

Each main Reflux menu is a standard FWT Menu instance, but is also configured as an IoC service and contributed to `afReflux.menuBar`. The menus use the following service IDs:

- `afReflux.fileMenu`
- `afReflux.editMenu`
- `afReflux.viewMenu`
- `afReflux.historyMenu`
- `afReflux.prefsMenu`
- `afReflux.helpMenu`

So, removing the history menu is as simple as:

```
@Contribute { serviceId="afReflux.menuBar" }
static Void contributeMenuBar(Configuration config) {
    config.remove("afReflux.historyMenu")
}
```

And to add your own menu:

```
@Contribute { serviceId="afReflux.menuBar" }
static Void contributeMenuBar(Configuration config) {
    config["example"] = Menu() { it.text = "Example"}
}
```

Use IoC ordering constraints to further position the menu:

```
@Contribute { serviceId="afReflux.menuBar" }
static Void contributeMenuBar(Configuration config) {
    menu := Menu() { it.text = "Example"}
    config
        .set("example", menu)
        .after("afReflux.editMenu")
        .before("afReflux.viewMenu")
}
```

### Menu Items

The menus services take contributions of `MenuItems`, so to add a *Hello Mum!* command to the edit menu:

```
@Contribute { serviceId="afReflux.editMenu" }
static Void contributeEditMenu(Configuration config, GlobalCommands globalCmds) {
    command := Command("Hello Mum!", null) |Event event| { echo("Hello Mum!") }
    config["myCommand"] = MenuItem(command)
}
```

Note that while a standard FWT command is used above, it is recomended that `RefluxCommands` are used so any invokation errors are routed to the `Errors` service for standardised handling. `GlobalCommands` may also be used.

Use IoC ordering constraints to further position any contributed commands / menu items. For example, to place the *Hello Mum!* command as the first item:

```
@Contribute { serviceId="afReflux.editMenu" }
static Void contributeEditMenu(Configuration config, GlobalCommands globalCmds) {
    command := Command("Hello Mum!", null) |Event event| { echo("Hello Mum!") }
    config
        .set("myCommand", MenuItem(command))
        .before("afReflux.cmdUndo")
}
```

When ordering menu items commands consult the source code of `RefluxModule` to find current contribution IDs, such as `afReflux.cmdUndo` above.

## Tool Bar

[#globalCommands]Global Commands 

[#eventing]Eventing 

