const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors());
app.use('/podcasts', express.static(path.join(__dirname, 'podcasts')));

let podcasts = [
    {
        id: 1,
        title: 'Podcast 1',
        cover: 'https://via.placeholder.com/300x300.png?text=Podcast+1',
        url: 'http://10.0.2.2:3000/podcasts/audio1.mp3',
        isFavorite: false,
        creator: 'Motive',
        description: 'açıklama'

    },
    {
        id: 2,
        title: 'Podcast 2',
        cover: 'https://via.placeholder.com/300x300.png?text=Podcast+2',
        url: 'http://10.0.2.2:3000/podcasts/audio2.mp3',
        isFavorite: false,
        creator: 'Motive',
        description: 'açıklama'
    },
];


// Ana sayfaya hoş geldiniz mesajı
app.get('/', (req, res) => {
    res.send('Podcast API\'ye Hoş Geldiniz');
});

// Tüm podcast'leri getirme
app.get('/podcasts', (req, res) => {
    res.json(podcasts);
});

// Belirli bir podcast'i favori olarak işaretleme
app.put('/podcasts/:id/favorite', (req, res) => {
    const podcastId = parseInt(req.params.id, 10);
    const podcast = podcasts.find(p => p.id === podcastId);
    if (podcast) {
        podcast.isFavorite = !podcast.isFavorite;
        res.json(podcast);
    } else {
        res.status(404).send('Podcast bulunamadı');
    }
});

app.listen(port, () => {
    console.log(`Sunucu http://localhost:${port} adresinde çalışıyor`);
});