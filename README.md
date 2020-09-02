# flutter_gx_gam



## pubspec.yaml

```yaml
flutter_gx_gam: 
    git:
      url:  git://github.com/fcrizul/flutter_gx_gam.git
```

```dart
GAMConfig.setProperties(
    baseUrl: "http://......com", 
    clientId: "aaaaaaaaaa",
    clientSecret: "bbbbbbbb",
    debug: true,
    checkAuthentication: (GAMUser user) async {
        ClienteResponse cliente = await UruboxService.getCliente();
        if (cliente != null){
            //....
        }
        return false;
    },
    checkPermission: (permission) async{
        return false;
    },
);
```
