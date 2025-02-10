# appSettings_ocaml

Example code:

```ocaml
type app_config = { foo : string }

module D = Decoders_yojson.Safe.Decode

let main_config_decoder : app_config D.decoder =
  let open D in
  let* foo = field "foo" string in
  succeed { foo }

let () =
  let paths =
    [ "appSettings.json" ]
    @ [
        (match Sys.getenv_opt "APP_ENV" with
        | Some "Production" -> "appSettings.Production.json"
        | _ -> "appSettings.Development.json");
      ]
  in
  let module C = AppSettings_ocaml.Config_provider.Make (D) in
  let config = C.(get_config paths ~decoder:main_config_decoder) in
  ...
```