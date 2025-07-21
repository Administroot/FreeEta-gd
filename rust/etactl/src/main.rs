use etalib::common::*;
use etalib::model::IData;
use std::{io::stdout, vec};
use crossterm::{
    style::{Color, Print, ResetColor, SetBackgroundColor, SetForegroundColor},
    ExecutableCommand,
};

use std::path::PathBuf;
use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about = "Event Tree Analysis Terminal of FreeEta")]
struct Cli {
    /// Load Components from file. (Support `CSV`, `JSON`, `TOML`)
    #[arg(short = 'i', long = "input", value_name = "FILE")]
    input_file: Option<PathBuf>,

    /// Export ETA (Event Tree Analysis) data to file, default `output.json`. (Support `CSV`, `JSON`, `TOML`)
    #[arg(short = 'o', long = "output", value_name = "FILE")]
    output_file: Option<PathBuf>,
}

fn main() -> std::io::Result<()> {
    let mut idata = IData{ components: vec![]};
    // Util: Clap
    let cli = Cli::parse();
    match cli.input_file.as_deref() {
        Some(path) => {
            stdout()
                .execute(SetForegroundColor(Color::DarkGreen))?
                .execute(Print("Parsing file ...... "))?
                .execute(ResetColor)?;

            match idata.deserialize(path) {
                Ok(_) => {
                    // TODO: Logic
                    algorithm(&mut idata);
                    stdout()
                        .execute(SetBackgroundColor(Color::DarkGreen))?
                        .execute(Print("Success"))?
                        .execute(ResetColor)?;
                },
                Err(e) => {
                    stdout()
                        .execute(SetBackgroundColor(Color::DarkRed))?
                        .execute(Print("Failed"))?
                        .execute(ResetColor)?;
                    let mut output = String::new();
                    output.push_str(&format!("\nDeserialize from {} failed: {}", path.display(), e));
                    stdout()
                        .execute(SetForegroundColor(Color::Red))?
                        .execute(Print(output))?
                        .execute(ResetColor)?;
                },
            };
        }
        None => {},
    };
    println!();
    match cli.output_file.as_deref() {
        Some(path) => {
            stdout()
                .execute(SetForegroundColor(Color::DarkGreen))?
                .execute(Print(&format!("Printing outputs to \'{}\' ...... ", path.display())))?
                .execute(ResetColor)?;
        },
        None => (),
    };

    Ok(())
}
