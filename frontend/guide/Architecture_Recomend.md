ApparenceKit architecture is based on 3 main layers

1. The data layer (API layer)
   This layer is responsible for fetching data from any source.
   It is also responsible for parsing and serialization.

Depending on if you are using a server, Firebase or Supabase you will have different classes in this layer.

This is also where we will request data to the secured storage or any other native plugin.

This is the only layer that isn't in our unit tests. We will test it with integration tests. Unit test doesn't communicate with the outside world. Integration test does. Read more about our unit test strategy

(Note: we use Riverpod to inject Api classes to repositories).

2. The domain layer
   This layer is responsible for the business logic of the app.
   It is where we will handle the data from the API layer and transform it to be used by the presentation layer. That is the responsibility of the repository classes.

Repositories are the only classes that can communicate with the API layer. But they are not reflecting the API layer. They are transforming the data to be used by the presentation layer. One repository can use multiple API classes if needed.

(Note: we use Riverpod to inject repositories classes to the presentation layer).

3. The presentation layer (VIEW)
   This is the last layer that will display the data to the user.
   It is where we will handle the UI and the user interactions.

It relies on repositories to get the data or do any other actions.

Before starting to code anything here you will have to learn about the Riverpod state management.

Briefly

our view will listen to an immutable state object from the Riverpod notifier
view can trigger actions that will update the state object
Structure
The template provides you with a structure that is already set up for you. It is split into 2 main folders:

core: where you will find the data and domain layer. But also all the common classes that are used in the whole app.
modules: Where you will find all the different features of your app. Every module are independent and can be removed or updated without any problem. A module can't communicate with another module. It can only communicate with the core layer.
The folder structure
Here is a brief overview of the folder structure:

├── core
│ ├── bottom_menu // bottom menu module
│ ├── data
│ │ ├── api // httpclient and api extensions + core api
│ │ ├── entities // function to help you create entities from json etc...
│ │ └── models
│ ├── guards // guards are used to protect routes
│ ├── initializer // app initializer
│ │ └── models
│ ├── rating // module that can be used by other modules
│ ├── security // security module (store user token, etc)
│ ├── shared_preferences // shared preferences module (store user preferences...)
│ ├── states // contains all the global states (user states)
│ │ └── models // models used by states
│ └── widgets
└── modules
└── module_1
├── api // a module can have its own api classes
│ └── entities // entities returned by api
├── domain // domain models returned by repositories
├── providers // riverpod providers for handling UI states
│ └── models // models for our page state
├── repositories // repositories are used to get domain from api
└── ui // pages, widgets, components, etc...
├── component // a component use a provider and domain  
 └── widgets // a widget is dumb and only using Flutter
Global states (core)
On modern app we need to keep some states that are shared between multiple modules.
For example, the user state, the subscription states...

That's why we have a global state folder in the core folder. These states will be used by multiple modules.

Check the user_state_notifier.dart file in the core/states folder to see an example of a global state.

App initializations (core)
The app initializer is a class that will be called when the app starts.

For example we needs to init the shared preferences, the security repository, the user state, etc... This should be done before the app starts. Once everything is started we knows where to go.

Check the onstart_widget.dart file in the core/initializer folder to see how the initializer works. This widget is called in the main.dart file and initialize everything before the app starts.

note: All the class to call by this initializer should implements the OnStartService interface.
