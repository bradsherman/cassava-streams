{-# LANGUAGE OverloadedStrings #-}

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
module Main (main) where

--------------------------------------------------------------------------------
import Control.Monad
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Csv hiding (Record, NamedRecord, record)
import qualified Data.Vector as V
import System.IO.Streams (InputStream, OutputStream)
import qualified System.IO.Streams as Streams
import qualified System.IO.Streams.Csv as CSV
import Test.QuickCheck.Monadic (monadicIO, run, assert)
import Test.Tasty
import Test.Tasty.QuickCheck as QC

--------------------------------------------------------------------------------
-- | Fake record to encode and decode.  This works well because
-- Cassava and QuickCheck already have the necessary instances for
-- triples.
type Record = (Int, String, String)

--------------------------------------------------------------------------------
-- | But, Cassava doesn't have ToNamedRecord, FromNamedRecord
-- instances for triples so we have to work around there here.
newtype NamedRecord = NamedRecord {record :: Record}

instance ToNamedRecord NamedRecord where
  toNamedRecord (NamedRecord (a, b, c)) =
    namedRecord ["a" .= a, "b" .= b, "c" .= c]

instance FromNamedRecord NamedRecord where
  parseNamedRecord m = do
    a <- m .: "a"
    b <- m .: "b"
    c <- m .: "c"
    return $ NamedRecord (a, b, c)


--------------------------------------------------------------------------------
header :: Header
header = V.fromList ["a", "b", "c"]

--------------------------------------------------------------------------------
-- | Given a list of records generated by QuickCheck, encode those
-- records into a CSV ByteString then decode them back into records.
roundTrip :: (InputStream ByteString  -> IO (InputStream a))  -- ^ Decoder.
          -> (OutputStream ByteString -> IO (OutputStream a)) -- ^ Encoder.
          -> [a]                                              -- ^ Records.
          -> IO [a]
roundTrip is os recs = do
  -- Encode records to a ByteString.
  sourceList <- Streams.fromList recs
  (collector, encoded) <- Streams.listOutputStream
  encoder <- os collector
  Streams.connect sourceList encoder

  -- Decode from ByteString.
  decoder <- fmap BS.concat encoded >>= Streams.fromByteString >>= is
  (decodeStream, decoded) <- Streams.listOutputStream
  Streams.connect decoder decodeStream
  decoded

--------------------------------------------------------------------------------
prop_namedRoundTrip :: [Record] -> Property
prop_namedRoundTrip recsIn = not (null recsIn) ==> monadicIO $ do
    recsOut <- run $ roundTrip is os (map NamedRecord recsIn)
    assert $ recsIn == map record recsOut
  where
    is = CSV.decodeStreamByName >=> CSV.onlyValidRecords
    os = CSV.encodeStreamByName header

--------------------------------------------------------------------------------
prop_indexedRoundTrip :: [Record] -> Property
prop_indexedRoundTrip recsIn = not (null recsIn) ==> monadicIO $ do
    recsOut <- run $ roundTrip is os recsIn
    assert $ recsIn == recsOut
  where
    is = CSV.decodeStream NoHeader >=> CSV.onlyValidRecords
    os = CSV.encodeStream

--------------------------------------------------------------------------------
tests :: TestTree
tests = testGroup "Tests"
        [ QC.testProperty "namedRoundTrip"   $ prop_namedRoundTrip
        , QC.testProperty "indexedRoundTrip" $ prop_indexedRoundTrip
        ]

--------------------------------------------------------------------------------
main :: IO ()
main = defaultMain tests