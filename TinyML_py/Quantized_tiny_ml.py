import torch
import torchvision
from torch import nn
import torchvision.transforms as transforms

transform = transforms.Compose(
    [transforms.Resize(size=(16, 16)),transforms.ToTensor(),
     transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))])

trainset = torchvision.datasets.CIFAR10(root='./data', train=True,
                                        download=False, transform=transform)
trainloader = torch.utils.data.DataLoader(trainset, batch_size=64,
                                          shuffle=True, num_workers=2)

testset = torchvision.datasets.CIFAR10(root='./data', train=False,
                                       download=False, transform=transform)
testloader = torch.utils.data.DataLoader(testset, batch_size=64,
                                         shuffle=False, num_workers=2)

classes = ('plane', 'car', 'bird', 'cat',
           'deer', 'dog', 'frog', 'horse', 'ship', 'truck')


class TinyML(nn.Module):
    def __init__(self, num_classes=10):
        super(TinyML, self).__init__()
        self.features = nn.Sequential(
            # 1
            nn.Conv2d(3, 16, kernel_size=3, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.MaxPool2d(kernel_size=2, stride=2),
            # 2
            nn.Conv2d(16, 8, kernel_size=3, padding=1),
            nn.BatchNorm2d(8),
            nn.ReLU(True),
        )
        self.classifier = nn.Sequential(
            nn.Linear(8 * 8 * 8, 512),
            nn.ReLU(True),
            nn.Dropout(),
            nn.Linear(512, 256),
            nn.ReLU(True),
            nn.Dropout(),
            nn.Linear(256, num_classes),
        )
        # self.classifier = nn.Linear(512, 10)

    def forward(self, x):
        out = self.features(x)
        #print(out.shape)
        #out = out.view(-1, 8 * 8 * 8)
        out = out.view(out.size(0), -1)
        #print(out.shape)
        out = self.classifier(out)
        #print(out.shape)
        return out



net = TinyML()


import torch.optim as optim

criterion = nn.CrossEntropyLoss()
optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)

for epoch in range(2):  # loop over the dataset multiple times
    for i, data in enumerate(trainloader, 0):
        # get the inputs; data is a list of [inputs, labels]
        inputs, labels = data

        # zero the parameter gradients
        optimizer.zero_grad()

        # forward + backward + optimize
        outputs = net(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        # print statistics
        if i % 16 == 0:    # print every 2000 mini-batches
            print(torch.argmax(outputs, 1), labels)
            print('[%d, %5d] loss: %.3f' %
                  (epoch + 1, i + 1, loss.item()))
            running_loss = 0.0

print('Finished Training')
torch.save(net.state_dict(), './TinyML.pth')