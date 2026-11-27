use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Journal {
    pub entries: Vec<Entry>
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct Entry {
    pub text: String,
    pub creation_date: String,
    pub time_zone: String,
    pub tags: Option<Vec<String>>,
    pub photos: Option<Vec<ImageData>>,
    pub location: Option<Location>
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct Location {
    pub place_name: Option<String>,
    pub address: Option<String>,
    pub longitude: f64,
    pub latitude: f64
}


#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct ImageData {
    pub identifier: String,
    pub md5: String
}
