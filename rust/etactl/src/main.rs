use etalib::common::*;
use std::io::stdout;
use crossterm::{
    style::{Color, Print, ResetColor, SetForegroundColor},
    ExecutableCommand,
};

use std::path::PathBuf;
use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about = "Event Tree Analysis Terminal of FreeEta")]
struct Cli {
    #[arg(short = 'i', long = "input", value_name = "FILE")]
    input_file: Option<PathBuf>,

    #[arg(short = 'o', long = "output", value_name = "FILE")]
    output_file: Option<PathBuf>,
}

fn main() -> std::io::Result<()> {
    // Clap
    let cli = Cli::parse();
    let input_msg = match cli.input_file.as_deref() {
        Some(input_file) => format!("Value of input: {}", input_file.display()),
        None => String::new(),
    };
    let output_msg = match cli.output_file.as_deref() {
        Some(output_file) => format!("Value of output: {}", output_file.display()),
        None => String::new(),
    };
    stdout()
        .execute(SetForegroundColor(Color::Cyan))?
        .execute(Print(&input_msg))?
        .execute(Print(&output_msg))?;
    // Crossterm
    let data = generate_rand(0u16);
    stdout()
        .execute(SetForegroundColor(Color::Yellow))?
        .execute(Print(print_rand_data(&data)))?
        .execute(ResetColor)?;
    Ok(())
}
