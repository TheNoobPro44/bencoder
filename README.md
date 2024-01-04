# bencoder
A luau module for encoding / decoding bencoded data


## Introduction
> Bencode (pronounced like B encode) is the encoding used by the peer-to-peer file sharing system BitTorrent for storing and transmitting loosely structured data.

### It supports four different types of values:
- strings
- numbers
- tables (array's and dictionary)
- boolean **(custom implementation made by me)**

# Example:
- `32` gets encoded to: `i32e`
- `false` gets encoded to: `b0e`
- `"Hello World"` gets encoded to: `11:Hello World`
- `{"foo", "bar"}` gets encoded to: `l3:foo3:bare`
- `{ foo = "bar" }` gets encoded to: `d3:foo3:bare`

# API
### Types:
```lua
type validTable = { [string | number | boolean] : string | number | boolean }
type validTypes = string | number | boolean | validTable
```
### Methods:
### `bencoder:encode(unencodedValue : validTypes): string`
- Takes any of the valid types as an argument, returns an encoded string.
### `bencoder:decode(encodedString : string): validTypes`
- Takes an encoded string as an argument, returns any of the valid types.
