# Usage

This docker provides access to the graphite web part of the graphite stack. It does not include the carbon/whisper part.

It is the intent to run this together with the visity/carbon, visity/statsd and grafana dockers.

Example, first start the carbon docker (see also visity/carbon):

	docker run -d -v $PWD/whisper/:/opt/graphite/storage/whisper/ --name carbon visity/carbon
	
Then start the graphiteweb docker:

	docker run -d --name graphiteweb --link carbon --volumes-from carbon -p 80:80 visity/graphiteweb

If you want NGINX to front graphite web, start the graphiteweb docker without the port mapping and start the standard nginx docker with the volumes from this docker:

	docker run -d --name nginx --volumes-from graphiteweb -p 8811:80 nginx
	