node jerry {
notify { "env": message => "ENVIRONMENT=production" }
}

node bania {
notify { "env": message => "ENVIRONMENT=production" }
}

node bubbleboy {
notify { "env": message => "ENVIRONMENT=production" }
}
