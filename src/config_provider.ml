let config_dir_path = Sys.getcwd ()

let read_file filename =
  let ic = open_in filename in
  try
    let rec read_lines acc =
      try
        let line = input_line ic in
        read_lines (line :: acc)
      with End_of_file ->
        close_in ic;
        List.rev acc
    in
    read_lines []
  with e ->
    close_in_noerr ic;
    raise e

type config_file = { name : string; body : string }

let get_config_files (paths : string list) =
  paths
  |> List.map (fun name ->
         let file_path = Filename.concat config_dir_path name in
         let body = file_path |> read_file |> String.concat "\n" in
         { name; body })

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
    |> List.map (fun (x : config_file) -> x.body |> Yojson.Safe.from_string)
    |> merge_jsons |> Yojson.Safe.pretty_to_string |> D.decode_string decoder
    |> CCResult.map_err D.string_of_error
    |> CCResult.get_or_failwith
end
