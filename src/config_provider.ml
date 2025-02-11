let config_dir_path = Sys.getcwd ()

let get_config_files (paths : string list) =
  paths
  |> List.map (fun name ->
         let file_path = Filename.concat config_dir_path name in
         file_path |> Fun.flip In_channel.with_open_text In_channel.input_all)

let merge_jsons jsons =
  let rec aux rest wip =
    match rest with
    | [] -> wip
    | h :: t -> (
        match (wip, h) with
        | `Assoc l1, `Assoc l2 ->
            aux t
              (`Assoc
                (List.fold_left
                   (fun acc (k, v) -> (k, v) :: List.remove_assoc k acc)
                   l1 l2))
        | _ -> h)
  in
  aux jsons (`Assoc [])

module Make (D : Decoders.Decode.S) = struct
  let get_config ~decoder paths =
    paths |> get_config_files
    |> List.map Yojson.Safe.from_string
    |> merge_jsons |> Yojson.Safe.pretty_to_string |> D.decode_string decoder
    |> CCResult.map_err D.string_of_error
    |> CCResult.get_or_failwith
end
