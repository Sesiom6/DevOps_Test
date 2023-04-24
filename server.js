var express = require('express');
var bodyParser = require('body-parser');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var mongoose = require('mongoose');

app.use(express.static(__dirname));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

var Message = mongoose.model('Message', {
  name: String,
  message: String,
});

const autoResponses = {
  'Oi': 'Olá! Como posso ajudar?',
  'Como vai?': 'Estou bem e você?',
  'Qual o seu nome?': 'Me chame de robôzin. Qual o seu nome?',
  'Quem te criou?' : 'Meu criador se chama Moisés, também conhecido como Sesiom!'
};

app.get('/messages', (req, res) => {
  Message.find({}, (err, messages) => {
    res.send(messages);
  });
});

app.get('/messages/:user', (req, res) => {
  var user = req.params.user;
  Message.find({ name: user }, (err, messages) => {
    res.send(messages);
  });
});

app.post('/messages', async (req, res) => {
  try {
    var message = new Message(req.body);

    var savedMessage = await message.save();
    console.log('saved');

    const autoResponse = autoResponses[req.body.message];
    if (autoResponse) {
      const responseMessage = new Message({
        name: 'Robôzin',
        message: autoResponse
      });
      await responseMessage.save();
      io.emit('message', responseMessage);
      console.log(`Autoresponse: ${autoResponse}`);
    } else {
      io.emit('message', req.body);
    }

    res.sendStatus(200);
  } catch (error) {
    res.sendStatus(500);
    return console.error('Error', error);
  } finally {
    console.log('Message Posted');
  }
});

io.on('connection', () => {
  console.log('A user is connected');
});

mongoose.connect(
  'mongodb+srv://sesiom:JaLuSNq97shpRsDf@cluster0.xmoxaja.mongodb.net/?retryWrites=true&w=majority',
  {
    useNewUrlParser: true,
    useUnifiedTopology: true
  },
  err => {
    console.log('MongoDB connected', err);
  }
);

var server = http.listen(3000, () => {
  console.log('Server is running on port', server.address().port);
});
