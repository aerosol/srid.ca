{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import qualified Clay as C
import Development.Shake
import Lucid
import qualified Neuron.Zettelkasten as Z
import qualified Neuron.Zettelkasten.Route as Z
import qualified Neuron.Zettelkasten.View as Z
import Path
import qualified Rib

main :: IO ()
main = Z.run (thisDir </> [reldir|content|]) (thisDir </> [reldir|dest|]) generateSite
  where
    thisDir = [reldir|example/srid.ca|]

generateSite :: Action ()
generateSite = do
  let writeHtmlRoute r = Rib.writeRoute r . Lucid.renderText . renderPage r
  Z.generateSite writeHtmlRoute [[relfile|*.md|]]

renderPage :: Z.Route s g a -> (s, g) -> Html ()
renderPage route val = with html_ [lang_ "en"] $ do
  head_ $ do
    meta_ [httpEquiv_ "Content-Type", content_ "text/html; charset=utf-8"]
    meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
    -- TODO: open graph
    title_ $ toHtml $ maybe siteTitle (<> " - " <> siteTitle) $
      Z.routeTitle (fst val) route
    stylesheet "https://cdn.jsdelivr.net/npm/semantic-ui@3.4.2/dist/semantic.min.css"
    style_ [type_ "text/css"] $ C.render Z.style
  body_ $ do
    div_ [class_ "ui text container"] $ do
      br_ mempty
      Z.renderRoute route val
  where
    siteTitle = "Example Zettelkasten"
    stylesheet x = link_ [rel_ "stylesheet", href_ x]
