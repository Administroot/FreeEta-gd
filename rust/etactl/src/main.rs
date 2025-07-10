mod model;

use etalib::common::*;
use std::io::stdout;
use crossterm::{
    style::{Color, Print, ResetColor, SetBackgroundColor, SetForegroundColor},
    ExecutableCommand,
};

use std::path::PathBuf;
use clap::Parser;

use model::{serialize_system_to_path, deserialize_system_from_path, System};

#[derive(Parser, Debug)]
#[command(author, version, about = "Event Tree Analysis Terminal of FreeEta")]
struct Cli {
    #[arg(short = 'i', long = "input", value_name = "FILE")]
    input_file: Option<PathBuf>,

    #[arg(short = 'o', long = "output", value_name = "FILE")]
    output_file: Option<PathBuf>,
}

fn main() -> std::io::Result<()> {
    // `sys`: JUST FOR TEST
    let sys = System::new();
    // Clap
    let cli = Cli::parse();
    let _input = match cli.input_file.as_deref() {
        Some(path) => {
            stdout()
                .execute(SetForegroundColor(Color::DarkGreen))?
                .execute(Print("Parsing file ...... "))?
                .execute(ResetColor)?;
            match deserialize_system_from_path(path) {
                Ok(_system) => {
                    // Logic
                    stdout().execute(Print("I've got system!"))?;
                    // Hint
                    stdout()
                        .execute(SetBackgroundColor(Color::DarkGreen))?
                        .execute(Print("Success"))?
                        .execute(ResetColor)?;
                    true
                }
                Err(e) => {
                    stdout()
                        .execute(SetBackgroundColor(Color::DarkRed))?
                        .execute(Print("Failed"))?
                        .execute(ResetColor)?;
                    let mut output = String::new();
                    output.push_str(&format!("\nFailed to deserialize system from {}: {}", path.display(), e));
                    stdout()
                        .execute(SetForegroundColor(Color::Red))?
                        .execute(Print(output))?
                        .execute(ResetColor)?;
                    false
                }
            }
        }
        None => false,
    };
    println!();
    let _output = match cli.output_file.as_deref() {
        Some(path) => {
            stdout()
                .execute(SetForegroundColor(Color::DarkGreen))?
                .execute(Print(&format!("Printing outputs to \'{}\' ...... ", path.display())))?
                .execute(ResetColor)?;
            match serialize_system_to_path(&sys, path) {
                Ok(()) => {
                    stdout()
                        .execute(SetBackgroundColor(Color::DarkGreen))?
                        .execute(Print("Success"))?
                        .execute(ResetColor)?;
                    true
                },
                Err(e) => {
                    stdout()
                        .execute(SetBackgroundColor(Color::DarkRed))?
                        .execute(Print("Failed"))?
                        .execute(ResetColor)?;
                    let mut output = String::new();
                    output.push_str(&format!("\nCannot write to {}: {}", path.display(), e));
                    stdout()
                        .execute(SetForegroundColor(Color::Red))?
                        .execute(Print(output))?
                        .execute(ResetColor)?;
                    false
                }
            }
        },
        None => false,
    };
    // Crossterm
    let data = generate_rand(0u16);
    stdout()
        .execute(SetForegroundColor(Color::Yellow))?
        .execute(Print(print_rand_data(&data)))?
        .execute(ResetColor)?;
    Ok(())
}
