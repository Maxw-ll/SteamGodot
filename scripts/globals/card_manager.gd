extends Node

var cards = {
	"capitao": {},
	"condessa": {},
	"embaixador": {},
	"assassino": {},
	"duque": {},
}

var deck = []

func create_shuffled_deck():
	for key in cards.keys():
		for i in range(3):
			deck.append(key)

	deck.shuffle()
	Console.log(str(deck))


func pop_card() -> String:
	return deck.pop_back()
