import Effects exposing (Effects)
import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attributes
import Http
import Signal
import Task

import DataLoader
import Respell
import StartApp

app =
  StartApp.start { init = init, update = update, view = view, inputs = [] }

main = app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
    app.tasks

type alias Model =
  { dataLoader : DataLoader.Model
  , userText : String
  , genText : String
  }

init : (Model, Effects Action)
init =
  ( { dataLoader = fst DataLoader.init, userText = "", genText = "" }
  , Effects.map DataLoaded <| snd DataLoader.init
  )

view : Signal.Address Action -> Model -> Html
view address model =
  Html.div []
    [ Html.div []
        [ Html.a
            [ Attributes.href
                "https://github.com/evanshort73/homophone/blob/master/LICENSE"
            ]
            [ Html.text "License" ]
        ]
    , Html.div []
        [ Html.textarea
            [ Events.on "input" Events.targetValue <|
                \x -> Signal.message address (EditText x)
            , Attributes.style
                [ ("width", "400px"), ("height", "200px") ]
            ]
            []
        ]
    , Html.div []
        [ Html.button
            [ Events.onClick address RespellText
            , Attributes.style
                [ ("padding", "10px 20px 10px 20px") ]
            ]
            [ Html.text "->" ]
        ]
    , Html.div []
        [ Html.text model.genText ]
    , Html.div []
        [ DataLoader.view model.dataLoader ]
    ]

type Action
  = EditText String
  | RespellText
  | DataLoaded DataLoader.Action
update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    DataLoaded subAction ->
      let subUpdate = DataLoader.update subAction model.dataLoader in
        ( { model | dataLoader = fst subUpdate }
        , Effects.map DataLoaded <| snd subUpdate
        )
    EditText newUserText ->
      ( { model | userText = newUserText }, Effects.none )
    RespellText ->
      ( { model
        | genText =
            case model.dataLoader of
              DataLoader.NotLoaded _ -> "not loaded"
              DataLoader.Loaded data -> Respell.respell data model.userText
        }
      , Effects.none
      )
