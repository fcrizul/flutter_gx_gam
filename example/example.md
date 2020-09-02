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