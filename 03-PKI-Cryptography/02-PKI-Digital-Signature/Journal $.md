**Erreur 1**
```
openssl req -new -engine pkcs11 -keyform engine -key "pkcs11:model=SoftHSM%20v2;manufacturer=SoftHSM%20project;serial=247e8903bf1b2f9e;token=recteur;object=recteur-key;type=private?pin-value=1234" -out recteur.csr -subj "/C=SN/ST=Senegal/O=UCAD/CN=Recteur UCAD"
Invalid engine "pkcs11"
00F34773A37F0000:error:12800067:DSO support routines:dlfcn_load:could not load the shared library:crypto/dso/dso_dlfcn.c:118:filename(/usr/lib64/engines-3/pkcs11.so): /usr/lib64/engines-3/pkcs11.so: cannot open shared object file: No such file or directory
00F34773A37F0000:error:12800067:DSO support routines:DSO_load:could not load the shared library:crypto/dso/dso_lib.c:147:
00F34773A37F0000:error:13000084:engine routines:dynamic_load:dso not found:crypto/engine/eng_dyn.c:438:
00F34773A37F0000:error:13000074:engine routines:ENGINE_by_id:no such engine:crypto/engine/eng_list.c:475:id=pkcs11
00F34773A37F0000:error:12800067:DSO support routines:dlfcn_load:could not load the shared library:crypto/dso/dso_dlfcn.c:118:filename(libpkcs11.so): libpkcs11.so: cannot open shared object file: No such file or directory
00F34773A37F0000:error:12800067:DSO support routines:DSO_load:could not load the shared library:crypto/dso/dso_lib.c:147:
00F34773A37F0000:error:13000084:engine routines:dynamic_load:dso not found:crypto/engine/eng_dyn.c:438:
No engine specified for loading private key
No filename or uri specified for loading
 private key
```

C'est parce que le plugin PKCS#11 pour OpenSSL `openssl-pkcs11` n'est pas installer sur fedora. Solution l'installer