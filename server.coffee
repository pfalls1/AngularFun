###global require, __dirname, process###

((express, dir, port = 3005) ->
	dir += '/dist'

	nextId = 0

	people = [
		{"id": "#{nextId++}", "name": "Saasha", "age": "5"}
		{"id": "#{nextId++}", "name": "Planet", "age": "7"}
	]

	getUrl = ->
		"http://localhost:#{port}"

	isUniqueName = (name) ->
		(name for person in people when person.name is name).length is 0

	open = (command = 'open') ->
		url = getUrl()
		ostype = require('os').type()
		command = 'explorer' if ostype is 'Windows_NT'
		spawn = require('child_process').spawn

		console.log "launching #{url}"

		spawn command, [url]

	app = express.createServer()

	app.configure ->
		app.set 'view options',
			layout: false

		app.use express.bodyParser()
		app.use express.static dir
		app.use app.router

		app.engine '.html', (str, options) ->
			(locals) ->
				str

		app.get '/', (req, res) ->
			res.render "#{dir}/index.html"

		app.get '/people', (req, res) ->
			res.json people

		app.get '/people/details/:id', (req, res) ->
			id = req.params.id
			current = person for person in people when parseInt(person.id, 10) is parseInt(id, 10)

			res.json current

		app.post '/people', (req, res) ->
			name = req.body.name

			message =
				"title": "Duplicate!"
				"message": "#{name} is a duplicate.  Please enter a new name."

			return res.send(message, 403) if not isUniqueName name

			person =
				"id": "#{nextId++}"
				"name": "#{name}"
				"age": "0"

			people.push person
			res.json person

		app.listen port, ->
			console.log "open your browser to the url below"
			console.log getUrl()

)(require('express'), __dirname, process.argv.splice(2)[0])