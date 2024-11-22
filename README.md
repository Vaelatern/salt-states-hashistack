# Salt states for nomad and consul AIOs

This is meant to run consul and nomad on Ubuntu and Void Linux systems

Of particular interest may be the "hashistack.nomad-aio" state, where AIO means All In One.

I've been using this for some years now. I do have some multi-node nomads but that automation hasn't yet been merged down into this work. The guts are all there.

My camera computers running frigate run the AIO states. My personal machines run hashistack-dev. There is an edge case where consul service discovery in particular does not like when a computer changes networks. This matters to my laptop.

All work is ISC licensed.
