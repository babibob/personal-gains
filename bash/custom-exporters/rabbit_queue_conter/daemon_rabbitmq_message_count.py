import os, time, requests, pika, shutil

from pika.exceptions import ChannelClosedByBroker, ChannelWrongStateError

while(True):
    with open('/tmp/rabbit_queue_count-daemon.file.draft', 'w+') as draftfile:
        params = pika.ConnectionParameters(host='10.117.0.4',port=5672,credentials=pika.credentials.PlainCredentials('<USER>', '<PASSWORD>'), )
        connection = pika.BlockingConnection(parameters=params)
        channel = connection.channel()

        def rest_queue_list(user='<USER>',password='<PASSWORD>',host='rabbitmq.example.com', port=443, virtual_host=None):
            url = 'https://%s:%s/api/queues/%s' % (host, port, virtual_host or '')
            response = requests.get(url, auth=(user, password))
            queues = [q['name'] for q in response.json()]
            return queues

        queue_list = rest_queue_list()
        for queue_name in queue_list:
            queue = channel.queue_declare(queue=queue_name,passive=True,durable=True,exclusive=False, auto_delete=False)
            count_messages = queue.method.message_count
#            print(f'rabbitmq_queue_message_count{{host="rabbitmq.mobile.yc.maf.io", queue_name=\"{queue_name}\"}} {count_messages}')
            draftfile.write(f'rabbitmq_queue_message_count{{host="rabbitmq.example.com", queue_name=\"{queue_name}\"}} {count_messages}\n')
        shutil.move('/tmp/rabbit_queue_count-daemon.file.draft', '/var/lib/prometheus/node-exporter/rabbit_queue_count-daemon.prom')
        draftfile.close()
        time.sleep(15)