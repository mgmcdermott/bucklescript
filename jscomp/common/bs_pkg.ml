
let (//) = Filename.concat

(** [resolve cwd module_name], 
    [cwd] is current working directory, absolute path
    Trying to find paths to load [module_name]
    it is sepcialized for option [-bs-package-include] which requires
    [npm_package_name/lib/ocaml]
*)
let  resolve_bs_package ~cwd name = 
  let sub_path = name // "lib" // "ocaml" in
  let rec aux origin cwd name = 
    let destdir =  cwd // Literals.node_modules // sub_path in 
    if Ext_sys.is_directory_no_exn destdir then destdir
    else 
      let cwd' = Filename.dirname cwd in 
      if String.length cwd' < String.length cwd then  
        aux origin   cwd' name
      else 
        try 
          let destdir = 
            Sys.getenv "npm_config_prefix" 
            // "lib" // Literals.node_modules // sub_path in
          if Ext_sys.is_directory_no_exn destdir
          then destdir
          else
            Bs_exception.error (Bs_package_not_found name)
        with 
          Not_found ->
          Bs_exception.error (Bs_package_not_found name)          
  in
  aux cwd cwd name