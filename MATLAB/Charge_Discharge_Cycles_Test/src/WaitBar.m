function WaitBar(WaitbarName, totalTime)

t = timer('TimerFcn', 'stat=false; disp("")', 'StartDelay', 10);
start(t);
stat = true;
count = 0;
f = waitbar(0, 'Start', 'Name', WaitbarName);

while stat == true

  count = count + 1;
  f = waitbar(count/totalTime, f, 'In progress ...');
  pause(1);

  if count == totalTime
      stop(t);
      delete(t);
      delete(f);
      break;
  end

end

end