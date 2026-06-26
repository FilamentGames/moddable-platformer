@abstract
extends Object
class_name AbstractMessagingInbox
## Abstract class that contains the main signals/properties of an object that the EditorGameMessagingService can access

## The ID of the object. This allows the messaging service to send messages to the correct recipient.
var id: int

## Emitted when the debugger responds with the current quest text
signal quest_text(text: String)

## Emitted when the debugger responds with the current collection of quest text that can be proceeded with the next button
signal all_nextbutton_quest_text(text: Array[String])

## Emitted when the debugger responds with the current number of scrolls
signal scroll_quantity(quantity: int)