FROM teamcloudyuga/python:alpine
COPY . /usr/src/app
WORKDIR /usr/src/app
ENV LINK http://www.meetup.com/cloudyuga/
ENV TEXT1 Globant CloudOps
ENV TEXT2 Welcome RSVP!!
ENV LOGO https://raw.githubusercontent.com/Avantika3012/MicroDepp/master/Globant%20image.PNG
ENV COMPANY Globant India Pvt. Ltd.
RUN pip3 install -r requirements.txt
CMD python rsvp.py
