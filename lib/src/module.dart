// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Associates types with their concrete instances returned by the [Injector]
abstract class Module {
    
    ///  register a [type] with [name] (optional) to an implementation
    Registration register(Type type, [String name = null]) {
        var registration = new Registration(type);
        var typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, name);
        _registrations[typeMirrorWrapper] = registration;
        return registration;
    }

    /// Configure type/instance registrations used in this module
    configure();

    /// Copies all bindings of [module] into this one.
    /// Overwriting when conflicts are found.
    void install(final Module module) {
        module.configure();
        _registrations.addAll(module._registrations);
    }

    bool _hasRegistrationFor(TypeMirror type, String name) =>
        _registrations.containsKey(new TypeMirrorWrapper(type, name));

    Registration _getRegistrationFor(TypeMirror type, String name) => _registrations[new TypeMirrorWrapper(type, name)];

    final Map<TypeMirrorWrapper, Registration> _registrations = new Map<TypeMirrorWrapper, Registration>();
}

/// Combines several [Module] into single one, allowing to inject
/// a class from one module into a class from another module.
class _ModuleContainer extends Module {
    _ModuleContainer(List<Module> this._modules);

    @override
    configure() {
        _modules.fold(_registrations, (acc, module) {
            module.configure();
            return acc..addAll(module._registrations);
        });
    }

    List<Module> _modules;
}
