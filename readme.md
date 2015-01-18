#Reflux v0.0.0
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v0.0.0](http://img.shields.io/badge/pod-v0.0.0-yellow.svg)](http://www.fantomfactory.org/pods/afReflux)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

A framework for creating a simple FWT desktop applications.

Fantom's core `flux` framework has the notion of being a URI browser. Reflux takes this idea and adds into the mix:

- **An IoC container** - Relflux applications are IoC applications.
- **Events** - An application wide eventing mechanism.
- **Customisation** - All aspects of a Reflux application may be customised.
- **Context sensitive commands** - Global commands may be enabled / disabled.
- **Browser session** - A consistent means to store session data.
- **New FWT widgits** - Fancy tabs and a working web browser.

The goal of Reflux is to be a customisable application framework; this differs to `flux` which is more of a static application with custom plugins.

> Reflux = Flux -> Reloaded.

## Install

Install `Reflux` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afReflux

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afReflux 0.0"]

## Documentation

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afReflux/).

![afReflux.ctabs.png](afReflux.ctabs.png)

## Quick Start

## Usage

### Panels

[Panels](http://repo.status302.com/doc/afReflux/Panel.html) are widget panes that decorate the edges of the main window. Only one instance of each panel type may exist. They are typically created at application startup and live until the application shutsdown.

To create a custom panel, extend [Panel](http://repo.status302.com/doc/afReflux/Panel.html) and contribute it to the `Panels` service:

