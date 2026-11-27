use std::{fs::{self, File, create_dir_all}, io::BufReader};

use chrono::{DateTime};
use chrono_tz::Tz;
use color_eyre::eyre::Result;
use regex::Regex;

use crate::schema::{Journal};

mod schema;

fn main() -> Result<()> {
    color_eyre::install()?;

    let file = File::open("Export-Journal/Journal.json")?;
    let reader = BufReader::new(file);
    let journal: Journal = serde_json::from_reader(reader)?;

    let dayone_moment_re = Regex::new(r"!\[\]\(dayone-moment://([A-Za-z0-9-]+)\)")?;

    for entry in journal.entries {
        let date = DateTime::parse_from_rfc3339(&entry.creation_date)?;
        let tz: Tz = entry.time_zone.parse()?;
        let date = date.with_timezone(&tz);

        let mut content: String = "---\ntags:\n".to_string();
        
        if let Some(tags) = entry.tags {
            for tag in tags {
                content += &format!("  - {}\n", tag);
            }
        }

        if let Some(location) = entry.location {
            content += "location:\n";
            content += &format!("  - {}\n", location.latitude);
            content += &format!("  - {}\n", location.longitude);
            if let Some(place_name) = location.place_name {
                content += &format!("place_name: {}\n", place_name.replace("\n", ""));
            }
            if let Some(address) = location.address {
                content += &format!("address: {}\n", address.replace("\n", ""));
            }
        }

        let image_ids: Vec<String> = dayone_moment_re
            .find_iter(&entry.text)
            .map(|m| m.as_str())
            .map(|m| m.chars().skip(20).take(32).collect())
            .collect();

        let mut image_locations: Vec<String> = vec![];
        if let Some(photos) = entry.photos {
            for id in image_ids {
                let matching_photos: Vec<_> = photos.iter()
                    .filter(|photo| photo.identifier == id).collect();
                let first = matching_photos.first();
                if let Some(first) = first {
                    image_locations.push(first.md5.clone());
                } else {
                    println!("WARN: No photos matched id {} in {}", id, date);
                }
            }
        }

        content += "images:\n";
        for image in &image_locations {
            content += &format!("  - {}.jpg\n", image)
        }

        content += "---\n";
        content += dayone_moment_re.replace_all(&entry.text, "").as_ref();

        let folder_path: String = date.format("out/%Y/%m/%d").to_string();
        create_dir_all(&folder_path)?;

        for image in &image_locations {
            let image_path = format!("Export-Journal/photos/{}.jpg", image);
            let target_path = format!("{}/{}.jpg", folder_path, image);
            fs::copy(image_path, target_path)?;
        }

        let file_path = folder_path + &date.format("/%H%M.md").to_string();
        fs::write(file_path, content)?;
    }

    Ok(())
}
