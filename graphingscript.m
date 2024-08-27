for x = 1:10 %running x times for greater accuracy

dataToPlot=[0;0];
delayMin=30;
delayMax=150;
for delay= delayMin:delayMax   

A=[0;0];
i=0;
t=0;
timeTable=[0;0]; 
timeInSecs=1800;   %time of pick up slot, assumed to be 30 min
carCount = 16;   %initial cars at location (will vary on LS, 5-6, or 7-8)
volumeInCars = 155; %total cars passing through pick up location
volumeInCars = volumeInCars - carCount;
%all setup^^^ (all preselections of variables)

settingUpCars=carCount; 
while(settingUpCars>0)  %to set up initial waiting cars
    A=[[settingUpCars;0] A]; %inserts to front of matrix
    settingUpCars=settingUpCars-1;  %moves to next car to set up   
end
A(:,end)=[];         %sets and displays starting queue

for t=1:7200            %duration of simulation (2 hrs)
A(2,:)=A(2,:)+1;         %increasing time by 1 each iteration
i = i+1; 
randN=rand(1);          %randomizer for car insertion
if (t<=timeInSecs)    %checking if still within time slot
if ((randN)<=(volumeInCars/timeInSecs))%check every second to insert car 
    carCount = carCount +1;   %increases car counting number
    A=[A [carCount;0]];    %adds new car to queue
end 
end
if(t<=delay)
if(A(2,1)>=delay)     %making sure the cars waited at least the delay val
timeTable=[timeTable A(:,1:6)]; %adding the TS of the first 6 cars
A(:,1:6)=[];       %removing the first 6 cars from the matrix  
i=0;
end 
elseif(i>=(delay/6))     
    i=0;                %checks when i has hit delay/6 minutes
if isempty(A)==0  %makes sure that next if doesn't go through empty matrix
if(A(2,1)>=delay)     %making sure the cars waited at least the delay val
timeTable=[timeTable A(:,1)]; %adding the TS of the car that just finished
A(:,1)=[];       %removing that car from the matrix  
end
end
end 
end 
timeTable(:,1)=[]; %removes leftover first element
timeTable; %display timetable (results per indiviual car)
timeTable = mean(timeTable, 2);  %taking the mean of all times for 1 delay
timeTable = [delay;(timeTable(2,1))/60]; %creating 
% delay to ATS & converting to seconds
dataToPlot = [dataToPlot timeTable];  %adding above table to full table
end
dataToPlot(:,1)=[];  %removing irrelevant first column
dataToPlot;
if(x==1)
megaTable = dataToPlot;    %creating final table that averages out values 
else
megaTable = megaTable + dataToPlot;  %preparing for the final average
end

end
megaTable = megaTable/x;  %taking average of x trials

f1=figure;
plot(megaTable(1,:),megaTable(2,:)) %will plot a line graph of data
xlabel("Pick up delay per car (s)") 
ylabel("Average time spent at pick up location (min)")
xAxis = transpose(megaTable(1,:)); %turning into column vector
yAxis = transpose(megaTable(2,:));  %turning into column vector
title("Effect of pick up time on time spent at pick up location")

f2=figure;
b=0;
for c = 1:20  %to find split point at which data goes from linear to exp.
    if(b~=1)
    avgTenTable = megaTable(2,(c-1)*10+1:(c-1)*10+10);
    avgTenTable2 = megaTable(2,(c-1)*10+10:(c-1)*10+19);
    if(sum(avgTenTable)*1.5)<sum(avgTenTable2)
        splitPoint=c*10;
        b=1;
    end
    end
end
linearMatrix=[];
expMatrix=[];
for d = 1:delayMax-delayMin
    if(d<splitPoint)
        linearMatrix = [linearMatrix megaTable(:,d)];
    end
    if(d>splitPoint)
        expMatrix = [expMatrix megaTable(:,d)];
    end
end
x2Axis = linearMatrix(1,:); %turning into column vector
y2Axis = linearMatrix(2,:);  %turning into column vector
p = polyfit(x2Axis,y2Axis,1);    %to get linear fit
scatter(x2Axis,y2Axis,5,"blue","filled")        
%will plot an linear fit with raw points
hold on;
yfit=p(1)*x2Axis + p(2);  %gathering linear fit data
plot(x2Axis,yfit)
hold on;
x3Axis = transpose(expMatrix(1,:)); %turning into exp vector
y3Axis = transpose(expMatrix(2,:));  %turning into column vector
f = fit(x3Axis,y3Axis,'exp1');    %to get exp fit
plot(f,x3Axis,y3Axis)        %will plot an exp fit with raw points
xlabel("Pick up delay per car (s)") 
ylabel("Average time spent at pick up location (min)")
title("Fit of effect of pick up time on time spent at pick up location")
