from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'THE API WORKS'


@app.route('/atdoor', methods=["POST"])
def testpost():
    input_json = request.get_json(force=True)
    door = input_json['door']
    person = input_json['person']
    # dictToReturn = {'door': input_json['door'], 'person': input_json['person']}
    return person + " is at the " + door + " door."


if __name__ == "__main__":
    app.run(debug=True)