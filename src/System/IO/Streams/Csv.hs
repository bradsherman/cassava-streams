{-

This file is part of the Haskell package cassava-streams. It is
subject to the license terms in the LICENSE file found in the
top-level directory of this distribution and at
git://pmade.com/cassava-streams/LICENSE. No part of cassava-streams
package, including this file, may be copied, modified, propagated, or
distributed except according to the terms contained in the LICENSE
file.

-}

--------------------------------------------------------------------------------
-- | This module exports functions which can be used to read instances
-- of the cassava classes @FromRecord@ and @FromNamedRecord@ from an
-- io-streams @InputStream ByteString@.
--
-- It also exports functions which can write instances of @ToRecord@
-- and @ToNamedRecord@ to an io-streams @OutputStream ByteString@.
--
-- See the "System.IO.Streams.Csv.Tutorial" module for a simple tutorial.
module System.IO.Streams.Csv
       ( -- * Decoding CSV
         -- | These functions convert an io-streams @InputStream
         -- ByteString@ stream into one that decodes CSV records and
         -- produces these decoded records.
         --
         -- Each of the decoding functions produce an @InputStream@
         -- which yields an @Either@ value.  @Left String@ represents
         -- a record which failed type conversion.  @Right a@ is a
         -- successfully decoded record.
         --
         -- See the tutorial in "System.IO.Streams.Csv.Tutorial" for
         -- details on how to use the 'onlyValidRecords' function to
         -- transform the decoding streams so that they only produce
         -- valid records and throw exceptions for bad records.
         module System.IO.Streams.Csv.Decode

         -- * Encoding CSV
         -- | These functions convert an io-streams @OutputStream
         -- ByteString@ stream into one that encodes records into CSV
         -- format before sending them downstream.
       , module System.IO.Streams.Csv.Encode

         -- * Convenience Exports
         -- | Export data types from Data.Csv
       , module Data.Csv
       ) where

--------------------------------------------------------------------------------
import System.IO.Streams.Csv.Decode
import System.IO.Streams.Csv.Encode

import Data.Csv ( HasHeader(..)
                , defaultEncodeOptions
                , defaultDecodeOptions
                , DecodeOptions(..)
                , EncodeOptions(..)
                , Quoting(..)
                )
